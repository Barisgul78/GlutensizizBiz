import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
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
import '../../../search/data/models/product.dart';
import '../../../search/data/services/search_service.dart';
import '../../../venues/data/models/venue.dart';
import '../../data/services/home_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Veri modelleri
// ─────────────────────────────────────────────────────────────────────────────

class _PopularTopic {
  final String name;
  final String articleCount;
  final Color iconBg;
  final IconData icon;
  const _PopularTopic(this.name, this.articleCount, this.iconBg, this.icon);
}

const _venueIconColors = [kPastelGreen, kPastelBlue, kPastelOrange, kPastelPink];

// ─────────────────────────────────────────────────────────────────────────────

const _popularTopics = [
  _PopularTopic(
      'Çölyak Hastalığı', '12 makale', kPastelGreen, Icons.eco_rounded),
  _PopularTopic('Glutensiz Tarifler', '6 makale', kPastelBlue,
      Icons.restaurant_menu_rounded),
  _PopularTopic('Belediye Destekleri', '9 makale', kPastelOrange,
      Icons.account_balance_rounded),
  _PopularTopic(
      'Güncel Haberler', '11 makale', kPastelPink, Icons.newspaper_rounded),
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
  Position? _userPosition;
  bool _loadingLocation = true;
  List<Venue> _venues = [];
  bool _loadingVenues = true;

  final _tips = TipsService.getAll();

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadVenues();
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

  Future<void> _loadVenues() async {
    try {
      final venues = await HomeService.fetchNearbyVenues();
      if (!mounted) return;
      setState(() {
        _venues = venues;
        _loadingVenues = false;
      });
    } catch (e) {
      debugPrint('Mekanlar yüklenemedi: $e');
      if (!mounted) return;
      setState(() => _loadingVenues = false);
    }
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
                  const SizedBox(height: AppSizes.xl),
                  _buildSectionHeader(
                    'Günün İpucu',
                    onTap: () => context.push('/tips'),
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
                    onTap: () => context.push('/venues'),
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
                initials(AuthService.isAnonymous
                    ? null
                    : AuthService.currentUser?.displayName),
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
            fontWeight: FontWeight.w500,
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
        try {
          return await SearchService.searchByName(query);
        } catch (e) {
          debugPrint('Arama önerisi yüklenemedi: $e');
          return <Product>[];
        }
      },
      itemBuilder: (context, product) => _searchResultCard(product),
      onSelected: (product) {
        _homeSearchCtrl.clear();
        context.push('/urun', extra: product);
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
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Glutensiz ürün veya mekan ara...',
                  hintStyle: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w500,
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
      onTap: () => context.push('/urun', extra: product),
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
                      fontWeight: FontWeight.w500,
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
      onTap: () => context.push('/tips/detay', extra: tip),
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
                      fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/venues/map', extra: {
              'center': _mapCenter,
              'hasUserLocation': _userPosition != null,
            }),
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
            child: _buildVenueList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    if (_loadingVenues) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_venues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Text(
          'Henüz mekan eklenmedi',
          style: GoogleFonts.sourceSans3(
            color: kOnSurfaceVariant,
            fontSize: AppSizes.fontSm + 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _venues.length; i++) _venueRow(_venues[i], i),
      ],
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

  Widget _venueRow(Venue venue, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs + 2),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _venueIconColors[index % _venueIconColors.length],
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
                  venue.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${venue.location} · ${venue.distance}',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: AppSizes.fontXs + 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            venue.rating,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSizes.sm + 4),
      ],
    );
  }
}
