import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../../../core/utils/date_utils.dart' as du;
import '../../../search/presentation/widgets/product_status_badge.dart';
import '../../../tips/presentation/widgets/category_badge.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../tips/data/services/tips_service.dart';
import '../../../tips/presentation/screens/tip_detail_screen.dart';
import '../../../tips/presentation/screens/tips_list_screen.dart';
import '../../../venues/presentation/screens/venues_screen.dart';
import '../../../venues/presentation/screens/venue_map_screen.dart';
import '../../../search/data/models/product.dart';
import '../../../search/data/services/search_service.dart';
import '../../../product_detail/presentation/screens/detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Veri modelleri — mock, ileride Firestore'a taşınacak
// ─────────────────────────────────────────────────────────────────────────────

class _QuickCategory {
  final String label;
  final IconData icon;
  final Color bgColor;
  const _QuickCategory(this.label, this.icon, this.bgColor);
}

class _PopularTopic {
  final String name;
  final String articleCount;
  final Color iconBg;
  final IconData icon;
  const _PopularTopic(this.name, this.articleCount, this.iconBg, this.icon);
}

class _Venue {
  final String name;
  final String district;
  final String distance;
  final double rating;
  final Color color;
  const _Venue(
      this.name, this.district, this.distance, this.rating, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────

const _quickCategories = [
  _QuickCategory('Yakındakiler', Icons.location_on_outlined, kPastelGreen),
  _QuickCategory('Yeni Ürünler', Icons.new_releases_outlined, kPastelBlue),
  _QuickCategory('Riskli İçerik', Icons.warning_amber_outlined, kPastelRed),
  _QuickCategory('Kampanyalar', Icons.local_offer_outlined, kPastelYellow),
];

const _popularTopics = [
  _PopularTopic('Çölyak Hastalığı', '12 makale', kPastelGreen, Icons.eco_rounded),
  _PopularTopic('Glutensiz Tarifler', '6 makale', kPastelBlue, Icons.restaurant_menu_rounded),
  _PopularTopic('Belediye Destekleri', '9 makale', kPastelOrange, Icons.account_balance_rounded),
  _PopularTopic('Güncel Haberler', '11 makale', kPastelPink, Icons.newspaper_rounded),
];

const _mockVenues = [
  _Venue('Flora Bistro', 'Kadıköy', '0.8 km', 4.8, kPastelGreen),
  _Venue('Green Kitchen', 'Beşiktaş', '1.2 km', 4.6, kPastelBlue),
];

// ─────────────────────────────────────────────────────────────────────────────
// Ana Ekran
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tipPageCtrl = PageController();
  final _homeSearchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();
  int _currentTipPage = 0;
  Future<List<Product>>? _productsFuture;
  Position? _userPosition;
  bool _loadingLocation = true;

  final _tips = TipsService.getAll();

  @override
  void initState() {
    super.initState();
    _productsFuture = SearchService.fetchAll();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    debugPrint('Konum yükleme başladı');
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _userPosition = pos;
      _loadingLocation = false;
    });
  }

  @override
  void dispose() {
    _tipPageCtrl.dispose();
    _homeSearchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'İyi sabahlar';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String _firstName() {
    if (AuthService.isAnonymous) return 'Misafir';
    final name = AuthService.currentUser?.displayName ?? '';
    return name.isEmpty ? 'Kullanıcı' : name.split(' ').first;
  }

  LatLng get _mapCenter => _userPosition != null
      ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
      : const LatLng(40.99, 29.03); // Kadıköy — placeholder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.lg),
                  _buildGreeting(),
                  const SizedBox(height: AppSizes.md),
                  _buildTypeAheadSearch(),
                  const SizedBox(height: AppSizes.lg),
                  _buildQuickCategories(),
                  const SizedBox(height: AppSizes.xl),
                  _buildSectionHeader(
                    'Günün İpucu',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const TipsListScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm + 4),
                  _buildTipsPageView(),
                  const SizedBox(height: AppSizes.xl),
                  _buildSectionHeader(
                    'Popüler Konular',
                    onTap: () => widget.onTabChange(2),
                  ),
                  const SizedBox(height: AppSizes.sm + 4),
                  _buildPopulerKonular(),
                  const SizedBox(height: AppSizes.xl),
                  _buildSectionHeader(
                    'Yakınındaki Mekanlar',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const VenuesScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm + 4),
                  _buildYakindakiMekanlar(),
                  const SizedBox(height: AppSizes.xl),
                  _buildHaftaninMarkasi(),
                  const SizedBox(height: AppSizes.xxl + AppSizes.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: AppSizes.screenPaddingH,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary,
            ),
            child: Center(
              child: Text(
                initials(AuthService.isAnonymous ? null : AuthService.currentUser?.displayName),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kOutlineVariant, width: 1.5),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: kOnSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Selamlama ─────────────────────────────────────────────────────────────
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
        const SizedBox(height: AppSizes.xs),
        Text(
          'Bugün glutensiz ne yiyeceğiz?',
          style: GoogleFonts.sourceSans3(
            color: kOnSurfaceVariant,
            fontSize: AppSizes.fontLg - 1,
          ),
        ),
      ],
    );
  }

  // ── TypeAhead Arama ───────────────────────────────────────────────────────
  Widget _buildTypeAheadSearch() {
    return TypeAheadField<Product>(
      controller: _homeSearchCtrl,
      focusNode: _searchFocusNode,
      hideOnEmpty: true,
      suggestionsCallback: (query) async {
        if (query.trim().isEmpty) return [];
        final products = await (_productsFuture ?? Future.value(<Product>[]));
        final q = query.trim().toLowerCase();
        return products
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q))
            .toList();
      },
      itemBuilder: (context, product) => _searchResultCard(product),
      onSelected: (product) {
        _homeSearchCtrl.clear();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              product: product,
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      builder: (context, controller, focusNode) => Container(
        height: 50,
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: kOnSurfaceVariant, size: 20),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: GoogleFonts.sourceSans3(
                  color: kOnSurface,
                  fontSize: AppSizes.fontMd,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Glutensiz ürün veya mekan ara...',
                  hintStyle: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: AppSizes.fontMd,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (ctx, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.clear();
                    focusNode.unfocus();
                  },
                  child: const Icon(Icons.close_rounded,
                      color: kOnSurfaceVariant, size: 20),
                );
              },
            ),
          ],
        ),
      ),
      decorationBuilder: (context, child) => Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        color: Colors.white,
        shadowColor: kOnSurface.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: kOnSurface.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            child: child,
          ),
        ),
      ),
      offset: const Offset(0, AppSizes.xs),
      constraints: const BoxConstraints(maxHeight: 400),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Center(child: CircularProgressIndicator(color: kPrimary)),
      ),
    );
  }

  Widget _searchResultCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            product: product,
            onBack: () => Navigator.pop(context),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm + 2),
        padding: const EdgeInsets.all(AppSizes.sm + 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm + 4),
                  child: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: kSurfaceContainerHighest,
                      child: const Icon(Icons.fastfood_rounded,
                          color: kOnSurfaceVariant, size: 24),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: ProductStatusBadge(status: product.status),
                ),
              ],
            ),
            const SizedBox(width: AppSizes.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: kOnSurface,
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: AppSizes.fontXs + 1,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: kOutlineVariant, size: AppSizes.iconMd),
          ],
        ),
      ),
    );
  }

  // ── Hızlı Kategoriler ─────────────────────────────────────────────────────
  Widget _buildQuickCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          _quickCategories.map((cat) => _quickCategoryButton(cat)).toList(),
    );
  }

  Widget _quickCategoryButton(_QuickCategory cat) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cat.bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(cat.icon, color: kOnSurfaceVariant, size: 24),
        ),
        const SizedBox(height: AppSizes.xs),
        SizedBox(
          width: 72,
          child: Text(
            cat.label,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: AppSizes.fontXs + 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Bölüm Başlığı ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: AppSizes.fontXl - 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onTap != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Tümü →',
              style: GoogleFonts.sourceSans3(
                color: kPrimary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Günün İpucu PageView ──────────────────────────────────────────────────
  Widget _buildTipsPageView() {
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _tipPageCtrl,
            itemCount: _tips.length,
            onPageChanged: (i) => setState(() => _currentTipPage = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: _tipCard(_tips[i]),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _tips.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs - 1),
              width: _currentTipPage == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentTipPage == i ? kPrimary : kOutlineVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tipCard(tip) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TipDetailScreen(tip: tip)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: kOnSurface.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel + badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusLg)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.asset(
                      tip.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: kPrimary,
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSizes.sm,
                  left: AppSizes.sm,
                  child: CategoryBadge(
                    label: tip.category,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm + 2, vertical: 3),
                    fontSize: AppSizes.fontXs + 1,
                  ),
                ),
              ],
            ),
            // İçerik
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: kOnSurface,
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    tip.summary,
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: AppSizes.fontSm + 1,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '${tip.author}  |  ${du.formatDate(tip.date)}',
                    style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant,
                      fontSize: AppSizes.fontXs + 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Popüler Konular 2x2 ───────────────────────────────────────────────────
  Widget _buildPopulerKonular() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.sm + 4,
      mainAxisSpacing: AppSizes.sm + 4,
      childAspectRatio: 1.4,
      children: _popularTopics.map((t) => _topicCard(t)).toList(),
    );
  }

  Widget _topicCard(_PopularTopic topic) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: kOnSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: topic.iconBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
            ),
            child: Icon(topic.icon,
                color: kOnSurfaceVariant, size: AppSizes.iconSm + 4),
          ),
          const Spacer(),
          Text(
            topic.name,
            style: GoogleFonts.plusJakartaSans(
              color: kOnSurface,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.xs - 1),
          Text(
            topic.articleCount,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: AppSizes.fontXs + 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Yakınındaki Mekanlar ──────────────────────────────────────────────────
  Widget _buildYakindakiMekanlar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: kOnSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mock harita
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VenueMapScreen(
                  center: _mapCenter,
                  hasUserLocation: _userPosition != null,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLg)),
              child: _buildMockMap(),
            ),
          ),
          // Mekan listesi
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Column(
              children: _mockVenues.map((v) => _venueRow(v)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMap() {
    final center = _mapCenter;

    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          IgnorePointer(
            child: FlutterMap(
              key: ValueKey(center),
              options: MapOptions(
                initialCenter: center,
                initialZoom: _userPosition != null ? 15 : 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.glufree.app',
                ),
                if (_userPosition != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: center,
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.my_location,
                          color: kPrimary, size: 28),
                    ),
                  ]),
              ],
            ),
          ),
          if (_loadingLocation)
            const Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _venueRow(_Venue venue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs + 2),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: venue.color,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
            ),
            child: const Icon(Icons.restaurant_rounded,
                color: kOnSurfaceVariant, size: 20),
          ),
          const SizedBox(width: AppSizes.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${venue.district} · ${venue.distance}',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: AppSizes.fontXs + 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            venue.rating.toString(),
            style: GoogleFonts.plusJakartaSans(
              color: kOnSurface,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Haftanın Markası ──────────────────────────────────────────────────────
  Widget _buildHaftaninMarkasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Haftanın Markası',
              style: GoogleFonts.plusJakartaSans(
                color: kOnSurface,
                fontSize: AppSizes.fontXl - 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm + 2, vertical: 3),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                'Önerilen',
                style: GoogleFonts.plusJakartaSans(
                  color: kPrimary,
                  fontSize: AppSizes.fontXs + 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm + 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: kOnSurface.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'N',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nustil',
                        style: GoogleFonts.plusJakartaSans(
                          color: kOnSurface,
                          fontSize: AppSizes.fontXl - 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Glutensiz Marka',
                        style: GoogleFonts.sourceSans3(
                          color: kOnSurfaceVariant,
                          fontSize: AppSizes.fontXs + 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm + 4),
              Text(
                'Tamamen glutensiz üretim hattı ile güvenli ürünler.',
                style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant,
                  fontSize: AppSizes.fontMd,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.sm + 4),
              Wrap(
                spacing: AppSizes.xs + 2,
                runSpacing: AppSizes.xs,
                children: ['Ekmek', 'Makarna', 'Kraker', 'Yulaf']
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm + 2, vertical: AppSizes.xs),
                        decoration: BoxDecoration(
                          color: kSurfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.sourceSans3(
                            color: kOnSurfaceVariant,
                            fontSize: AppSizes.fontXs + 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
