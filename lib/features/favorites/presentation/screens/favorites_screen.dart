import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../search/data/models/product.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/services/favorites_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../tips/data/models/tip.dart';
import '../../../tips/data/services/tips_service.dart';
import '../../../tips/presentation/screens/tip_detail_screen.dart';
import '../../../tips/presentation/widgets/category_badge.dart';
import '../../../tips/presentation/widgets/tip_image.dart';
import '../../../../../core/utils/date_utils.dart' as du;

class FavoritesScreen extends StatefulWidget {
  final Function(Product) onProductSelect;

  const FavoritesScreen({super.key, required this.onProductSelect});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String selectedTab = 'Ürünler';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSwitcher(),
            const SizedBox(height: 12),
            Expanded(
              child: selectedTab == 'Ürünler'
                  ? _buildProductsList()
                  : selectedTab == 'Mekanlar'
                      ? _buildVenuesList()
                      : _buildArticlesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary,
            ),
            child: Center(
              child: Text(
                initials(AuthService.currentUser?.displayName),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Favoriler',
            style: GoogleFonts.plusJakartaSans(
              color: kOnSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kSurfaceContainerHigh,
            ),
            child: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kOutlineVariant),
        ),
        child: Row(
          children: [
            Expanded(child: _tabButton('Ürünler')),
            Expanded(child: _tabButton('Mekanlar')),
            Expanded(child: _tabButton('Makaleler')),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String title) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? kOnPrimary : kOnSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    final userId = AuthService.currentUserId;

    if (userId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Favorilerinizi görmek için\ngiriş yapmanız gerekiyor.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: FavoritesService.favoritesStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimary));
        }

        final data = snapshot.data;
        final List<String> productIds = (data != null && data.exists)
            ? List<String>.from((data.data() as Map?)?['urun_idleri'] ?? [])
            : [];

        if (productIds.isEmpty) {
          return Center(
            child: Text(
              'Henüz favori ürün eklemediniz.',
              style: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          );
        }

        return FutureBuilder<List<Product>>(
          future: FavoritesService.fetchProductsByIds(productIds.take(10).toList()),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kPrimary));
            }

            final products = productSnapshot.data ?? [];
            if (products.isEmpty) {
              return Center(
                child: Text('Ürünler yüklenemedi.',
                    style: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontWeight: FontWeight.w500)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductCard(products[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildVenuesList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_outlined, color: kOutlineVariant, size: 52),
            const SizedBox(height: 16),
            Text(
              'Favori mekan bulunamadı',
              style: GoogleFonts.plusJakartaSans(
                color: kOnSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mekanlar sekmesinden beğendiğiniz mekanlarda kalp ikonuna basarak favorilerinize ekleyebilirsiniz.',
              style: GoogleFonts.sourceSans3(
                color: kOnSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList() {
    final userId = AuthService.currentUserId;

    if (userId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Favorilerinizi görmek için\ngiriş yapmanız gerekiyor.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: FavoritesService.favoritesStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimary));
        }

        final data = snapshot.data;
        final List<String> tipIds = (data != null && data.exists)
            ? List<String>.from((data.data() as Map?)?['makale_idleri'] ?? [])
            : [];

        if (tipIds.isEmpty) {
          return Center(
            child: Text(
              'Kayıtlı makale bulunamadı.',
              style: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          );
        }

        final tips = TipsService.getAll().where((t) => tipIds.contains(t.id)).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: tips.length,
          itemBuilder: (context, index) => _buildArticleCard(tips[index]),
        );
      },
    );
  }

  Widget _buildArticleCard(Tip tip) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TipDetailScreen(tip: tip)),
      ),
      child: Container(
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
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: TipImage(asset: tip.imageAsset),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: CategoryBadge(
                    label: tip.category,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    fontSize: 9,
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
                    tip.author.toUpperCase(),
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tip.title,
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
                    du.formatDate(tip.date),
                    style: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await FavoritesService.toggleArticleFavorite(tip.id, isFavorite: true);
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.bookmark_rounded, color: kSecondary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => widget.onProductSelect(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOutlineVariant),
        ),
        child: Row(
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
                  child: const Icon(Icons.fastfood, color: kOnSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  _statusBadge(product.status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.favorite_border, color: kSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ProductStatus status) {
    final Color bg;
    final Color fg;
    final String text;
    switch (status) {
      case ProductStatus.safe:
        bg = kPrimaryFixed;
        fg = kPrimary;
        text = 'Glutensiz';
      case ProductStatus.risky:
        bg = kErrorContainer;
        fg = kOnErrorContainer;
        text = 'Riskli';
      case ProductStatus.unknown:
        bg = kSurfaceContainerHigh;
        fg = kOnSurfaceVariant;
        text = 'Bilinmiyor';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

}

