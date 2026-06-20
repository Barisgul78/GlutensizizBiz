import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../search/data/models/product.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Product>>? _newProductsFuture;
  Future<List<Product>>? _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _newProductsFuture = _fetchNewProducts();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<Product>> _fetchNewProducts() async {
    final snap = await FirebaseFirestore.instance
        .collectionGroup('marka_urunleri')
        .limit(6)
        .get();
    return snap.docs
        .map((d) => Product.fromFirestore(d.data()))
        .toList();
  }

  Future<List<Product>> _fetchFavorites() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return [];
    final favDoc = await FirebaseFirestore.instance
        .collection('favoriler')
        .doc(userId)
        .get();
    if (!favDoc.exists) return [];
    final ids = List<String>.from(favDoc.data()?['urun_idleri'] ?? []);
    if (ids.isEmpty) return [];
    final snap = await FirebaseFirestore.instance
        .collectionGroup('marka_urunleri')
        .where('id', whereIn: ids.take(10).toList())
        .get();
    return snap.docs
        .map((d) => Product.fromFirestore(d.data()))
        .toList();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String _firstName() {
    if (AuthService.isAnonymous) return 'Misafir';
    final name = AuthService.currentUser?.displayName ?? '';
    return name.isEmpty ? 'Kullanıcı' : name.split(' ').first;
  }

  String _initials() {
    if (AuthService.isAnonymous) return '?';
    final name = AuthService.currentUser?.displayName ?? '';
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildDailyTip(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Yeni Eklenenler'),
                  const SizedBox(height: 14),
                  _buildNewProducts(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Favorilerim'),
                  const SizedBox(height: 14),
                  _buildFavorites(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary,
              border: Border.all(color: kOutlineVariant, width: 1.5),
            ),
            child: Center(
              child: Text(
                _initials(),
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
            'GluFree',
            style: GoogleFonts.plusJakartaSans(
              color: kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
            child: const Icon(Icons.notifications_outlined,
                color: kOnSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting()}, ${_firstName()}!',
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Bugün glutensiz ne yiyeceğiz?',
          style: GoogleFonts.sourceSans3(
            color: kOnSurfaceVariant,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            label: 'Ürün Tara',
            icon: Icons.qr_code_scanner,
            bgColor: kSurfaceContainerHigh,
            iconColor: kPrimary,
            onTap: () => widget.onTabChange(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            label: 'Ürün Ara',
            icon: Icons.search_rounded,
            bgColor: kPrimaryContainer,
            iconColor: kOnPrimaryContainer,
            onTap: () => widget.onTabChange(1),
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 14),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: iconColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://picsum.photos/seed/glutentip/600/338',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kSurfaceContainerHighest,
                  child: const Icon(Icons.restaurant,
                      color: kOnSurfaceVariant, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kTertiaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Günün İpucu',
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Etiket okumak hayat kurtarır',
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Glutensiz ürünleri satın alırken "nişasta", "buğday proteini" ve "malt" ifadelerine dikkat edin.',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: kOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Devamını Oku',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => widget.onTabChange(1),
          style: TextButton.styleFrom(
            foregroundColor: kPrimary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Tümünü Gör',
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewProducts() {
    return FutureBuilder<List<Product>>(
      future: _newProductsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: kPrimary)),
          );
        }
        final products = snap.data ?? [];
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Henüz ürün eklenmemiş.',
              style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant, fontSize: 14),
            ),
          );
        }
        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _productCard(products[i]),
          ),
        );
      },
    );
  }

  Widget _productCard(Product product) {
    final isGlutenFree = product.status == ProductStatus.safe;
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kSurfaceContainerHighest,
                  child: const Icon(Icons.fastfood, color: kOnSurfaceVariant),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isGlutenFree ? Icons.check_circle : Icons.warning_amber,
                      color: isGlutenFree ? kPrimary : kSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isGlutenFree ? 'Glutensiz' : 'Gluten var',
                        style: GoogleFonts.sourceSans3(
                          color: isGlutenFree ? kPrimary : kSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites() {
    final userId = AuthService.currentUserId;
    if (AuthService.isAnonymous || userId == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Favorilerinizi görmek için giriş yapın.',
          style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant, fontSize: 14),
        ),
      );
    }

    return FutureBuilder<List<Product>>(
      future: _favoritesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: kPrimary)),
          );
        }
        final products = snap.data ?? [];
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Henüz favori ürün eklemediniz.',
              style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant, fontSize: 14),
            ),
          );
        }
        return Column(
          children: products.map(_favoriteRow).toList(),
        );
      },
    );
  }

  Widget _favoriteRow(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kSurfaceContainerHighest,
                  child: const Icon(Icons.fastfood,
                      color: kOnSurfaceVariant, size: 20),
                ),
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
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.brand,
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: kSecondaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: kSecondary, size: 18),
          ),
        ],
      ),
    );
  }
}
