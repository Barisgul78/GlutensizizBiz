import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product.dart';
import '../../data/services/search_service.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../favorites/data/services/favorites_service.dart';
import '../../../profile/data/services/stats_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/product_status_badge.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> recentSearches = [];
  String selectedCategory = 'Tümü';
  Future<List<Product>>? _popularProductsFuture;

  List<Product> _searchResults = [];
  DocumentSnapshot? _lastSearchDoc;
  bool _searchHasMore = true;
  bool _searchLoading = false;
  bool _searchLoadingMore = false;
  Object? _searchError;
  Timer? _debounce;
  int _searchRequestId = 0;

  static const _categories = [
    'Tümü',
    'Ekmek & Pasta',
    'Makarna',
    'Atıştırmalık',
    'İçecek'
  ];

  @override
  void initState() {
    super.initState();
    _popularProductsFuture = SearchService.fetchFeatured();
    _loadRecentSearches();
    _scrollController.addListener(_onScroll);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      query = widget.initialQuery!.trim().toLowerCase();
      _startNewSearch(query);
    }
  }

  void _onScroll() {
    if (query.isEmpty ||
        !_searchHasMore ||
        _searchLoading ||
        _searchLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreSearchResults();
    }
  }

  Future<void> _startNewSearch(String q) async {
    final requestId = ++_searchRequestId;
    setState(() {
      _searchResults = [];
      _lastSearchDoc = null;
      _searchHasMore = true;
      _searchError = null;
      _searchLoading = true;
    });
    try {
      final page = await SearchService.searchByName(q);
      // Beklerken yeni bir arama başlamışsa bu cevap eski (stale) demektir, yok say.
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchResults = page.items;
        _lastSearchDoc = page.lastDocument;
        _searchHasMore = page.hasMore;
        _searchLoading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchError = e;
        _searchLoading = false;
      });
    }
  }

  Future<void> _loadMoreSearchResults() async {
    final requestId = _searchRequestId;
    setState(() => _searchLoadingMore = true);
    try {
      final page =
          await SearchService.searchByName(query, startAfter: _lastSearchDoc);
      // Sayfalama beklerken yeni bir arama başlamışsa bu sayfa eski aramaya ait, yok say.
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchResults = [..._searchResults, ...page.items];
        _lastSearchDoc = page.lastDocument;
        _searchHasMore = page.hasMore;
        _searchLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Sonraki sayfa yüklenemedi: $e');
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => _searchLoadingMore = false);
    }
  }

  void _onQueryChanged(String value) {
    final q = value.trim();
    setState(() => query = q.toLowerCase());
    _debounce?.cancel();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _lastSearchDoc = null;
        _searchHasMore = true;
        _searchError = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _startNewSearch(q);
    });
  }

  void _retrySearch() {
    _startNewSearch(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _toggleFavoriteFromSearch(Product product) async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilere eklemek için giriş yapmanız gerekiyor.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    await FavoritesService.addProductFavorite(product.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} favorilere eklendi!'),
          duration: const Duration(seconds: 1),
          backgroundColor: kPrimary,
        ),
      );
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        recentSearches = prefs.getStringList('recentSearches') ?? [];
      });
    }
  }

  Future<void> _saveSearch(String productName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches.remove(productName);
      recentSearches.insert(0, productName);
      if (recentSearches.length > 5) recentSearches.removeLast();
    });
    await prefs.setStringList('recentSearches', recentSearches);
  }

  void _onSearchSubmitted(String value) {
    final userId = AuthService.currentUserId;
    if (userId != null && value.trim().isNotEmpty) {
      StatsService.incrementSearchCount(userId);
    }
  }

  Future<void> _clearSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentSearches');
    setState(() => recentSearches.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (query.isNotEmpty) _buildLiveSearchList(),
                    if (query.isEmpty) ...[
                      if (recentSearches.isNotEmpty) _buildRecentSearches(),
                      _buildPopularSection(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ürün Ara',
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Güvenilir glutensiz ürünleri keşfedin',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kSurfaceContainerHigh,
            ),
            child: const Icon(Icons.notifications_outlined,
                color: kOnSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOutlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: kOnSurfaceVariant, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.sourceSans3(
                    color: kOnSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
                onChanged: _onQueryChanged,
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Ürün, marka veya kategori...',
                  hintStyle: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Barkod tarayıcı açılacak (ileride eklenecek)
              },
              child:
                  const Icon(Icons.qr_code_scanner, color: kPrimary, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kPrimary : kSurfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: isSelected ? kPrimary : kOutlineVariant),
              ),
              child: Text(
                cat,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? kOnPrimary : kOnSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aramalar',
                style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              GestureDetector(
                onTap: _clearSearches,
                child: Text('Temizle',
                    style: GoogleFonts.sourceSans3(
                        color: kPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: recentSearches.map(_recentSearchTag).toList()),
          ),
        ],
      ),
    );
  }

  Widget _recentSearchTag(String text) {
    return GestureDetector(
      onTap: () {
        _debounce?.cancel();
        _searchController.text = text;
        query = text.toLowerCase();
        _startNewSearch(query);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kOutlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: kOnSurfaceVariant, size: 14),
            const SizedBox(width: 6),
            Text(text,
                style: GoogleFonts.sourceSans3(
                    color: kOnSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popüler Ürünler',
            style: GoogleFonts.plusJakartaSans(
                color: kOnSurface, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Product>>(
            future: _popularProductsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                );
              }
              final products = snap.data ?? [];
              if (products.isEmpty) {
                return Text(
                  'Henüz ürün eklenmemiş.',
                  style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                );
              }
              return Column(
                children: products.map((product) {
                  return GestureDetector(
                    onTap: () => context.push('/urun', extra: product),
                    child: _popularCard(
                      name: product.name,
                      brand: product.brand,
                      category: product.category,
                      status: product.status,
                      imageUrl: product.imageUrl,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _popularCard({
    required String name,
    required String brand,
    required String category,
    required ProductStatus status,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutlineVariant),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: kSurfaceContainerHighest,
                    child: const Icon(Icons.fastfood, color: kOnSurfaceVariant),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: ProductStatusBadge(
                  status: status,
                  borderRadius: 5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.toUpperCase(),
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kSurfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kOutlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildLiveSearchList() {
    if (_searchLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: kPrimary),
        ),
      );
    }

    if (_searchError != null) {
      debugPrint('Ürün yükleme hatası: $_searchError');
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ürünler yüklenirken bir hata oluştu.',
              style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _retrySearch,
              style: TextButton.styleFrom(
                foregroundColor: kPrimary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Tekrar Dene',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final results = _searchResults;

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Text(
          '"$query" ile eşleşen ürün bulunamadı.',
          style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            '${results.length} sonuç',
            style: GoogleFonts.sourceSans3(
                color: kOnSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: results.length + (_searchLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= results.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child:
                    Center(child: CircularProgressIndicator(color: kPrimary)),
              );
            }
            return _buildSearchResultCard(context, results[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        _saveSearch(product.name);
        context.push('/urun', extra: product);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kOnPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kOnSurface.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: kSurfaceContainerHighest,
                      child:
                          const Icon(Icons.fastfood, color: kOnSurfaceVariant),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: ProductStatusBadge(
                    status: product.status,
                    borderRadius: 5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: kOnSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _toggleFavoriteFromSearch(product),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.favorite_border, color: kSecondary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
