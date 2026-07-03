import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../widgets/category_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Veri modelleri
// ─────────────────────────────────────────────────────────────────────────────

class _GuideItem {
  final String name;
  final String articleCount;
  final String subtitle;
  final Color iconBg;
  final IconData icon;
  final String? badge;
  final Color? badgeBg;
  final Color? badgeText;

  const _GuideItem({
    required this.name,
    required this.articleCount,
    required this.subtitle,
    required this.iconBg,
    required this.icon,
    this.badge,
    this.badgeBg,
    this.badgeText,
  });
}

class _GuideGroup {
  final String title;
  final List<_GuideItem> items;
  const _GuideGroup(this.title, this.items);
}

const _groups = [
  _GuideGroup('SAĞLIK & HASTALIK', [
    _GuideItem(
      name: 'Çölyak Hastalığı',
      articleCount: '12 makale',
      subtitle: 'Tanı, belirtiler, tedavi',
      iconBg: kPastelGreen,
      icon: Icons.eco_rounded,
    ),
    _GuideItem(
      name: 'Sağlık İpuçları',
      articleCount: '10 makale',
      subtitle: 'Vitamin, takviye, eksiklik',
      iconBg: kPastelBlue,
      icon: Icons.health_and_safety_outlined,
    ),
    _GuideItem(
      name: 'Çocuklarda Çölyak',
      articleCount: '8 makale',
      subtitle: 'Ebeveyn rehberi, okul, tarifler',
      iconBg: kPastelPink,
      icon: Icons.child_care_rounded,
      badge: 'Yeni',
      badgeBg: kPastelRed,
      badgeText: kBadgeDanger,
    ),
  ]),
  _GuideGroup('BESLENME & TARİFLER', [
    _GuideItem(
      name: 'Glutensiz Tarifler',
      articleCount: '6 makale',
      subtitle: 'Kullanıcı tarifleri, pratik öneriler',
      iconBg: kPastelOrange,
      icon: Icons.restaurant_menu_rounded,
    ),
    _GuideItem(
      name: 'Diyet Listeleri',
      articleCount: '8 makale',
      subtitle: 'Haftalık planlar, öğün önerileri',
      iconBg: kPastelGreen,
      icon: Icons.checklist_rounded,
    ),
    _GuideItem(
      name: 'Etiket Okuma Rehberi',
      articleCount: '7 makale',
      subtitle: 'Gizli gluten, E kodları',
      iconBg: kPastelGray,
      icon: Icons.label_outlined,
    ),
  ]),
  _GuideGroup('YAŞAM & DESTEK', [
    _GuideItem(
      name: 'Belediye Destekleri',
      articleCount: '9 makale',
      subtitle: 'Konuma göre yardımlar',
      iconBg: kPastelGreen,
      icon: Icons.account_balance_rounded,
      badge: 'Lokasyon',
      badgeBg: kPastelGreen,
      badgeText: kBadgeSuccess,
    ),
    _GuideItem(
      name: 'Alışveriş Rehberi',
      articleCount: '11 makale',
      subtitle: 'Market, marka önerileri',
      iconBg: kPastelYellow,
      icon: Icons.shopping_cart_outlined,
    ),
    _GuideItem(
      name: 'Güncel Haberler',
      articleCount: '11 makale',
      subtitle: 'Araştırmalar, yeni ürünler',
      iconBg: kPastelBlue,
      icon: Icons.newspaper_rounded,
      badge: 'Güncellendi',
      badgeBg: kPastelBlue,
      badgeText: kBadgeInfo,
    ),
  ]),
];

// ─────────────────────────────────────────────────────────────────────────────
// Rehber Ekranı
// ─────────────────────────────────────────────────────────────────────────────

class RehberScreen extends StatefulWidget {
  const RehberScreen({super.key});

  @override
  State<RehberScreen> createState() => _RehberScreenState();
}

class _RehberScreenState extends State<RehberScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_GuideGroup> get _filtered {
    if (_query.isEmpty) return _groups;
    final q = _query.toLowerCase();
    return _groups
        .map((g) => _GuideGroup(
              g.title,
              g.items
                  .where((i) => i.name.toLowerCase().contains(q) ||
                      i.subtitle.toLowerCase().contains(q))
                  .toList(),
            ))
        .where((g) => g.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSizes.screenPaddingH,
        title: Text(
          'Rehber',
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kOutlineVariant, width: 1.5),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: kOnSurfaceVariant, size: 18),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPaddingH,
              vertical: AppSizes.sm,
            ),
            child: _buildSearchBar(),
          ),
          // Gruplu liste
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: AppSizes.screenPaddingH,
                      right: AppSizes.screenPaddingH,
                      bottom: AppSizes.xxl,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildGroup(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
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
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.sourceSans3(
                  color: kOnSurface, fontSize: AppSizes.fontMd, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Konularda ara...',
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
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
              child: const Icon(Icons.close_rounded,
                  color: kOnSurfaceVariant, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildGroup(_GuideGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text(
          group.title,
          style: GoogleFonts.sourceSans3(
            color: kOnSurfaceVariant,
            fontSize: AppSizes.fontXs + 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        ...group.items.map((item) => _buildItem(item)),
      ],
    );
  }

  Widget _buildItem(_GuideItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs + 2),
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            onTap: () {}, // ileride kategori detay sayfasına gidecek
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  // İkon kutusu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm + 4),
                    ),
                    child: Icon(item.icon,
                        color: kOnSurfaceVariant,
                        size: AppSizes.iconMd),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  // İçerik
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: GoogleFonts.plusJakartaSans(
                                  color: kOnSurface,
                                  fontSize: AppSizes.fontLg - 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (item.badge != null) ...[
                              const SizedBox(width: AppSizes.xs),
                              CategoryBadge(
                                label: item.badge!,
                                bgColor: item.badgeBg!,
                                fgColor: item.badgeText!,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm, vertical: 2),
                                fontSize: AppSizes.fontXs,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs - 1),
                        Text(
                          '${item.articleCount} · ${item.subtitle}',
                          style: GoogleFonts.sourceSans3(
                            color: kOnSurfaceVariant,
                            fontSize: AppSizes.fontXs + 2,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.xs),
                  const Icon(Icons.chevron_right_rounded,
                      color: kOutlineVariant, size: AppSizes.iconMd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              color: kOutlineVariant, size: 48),
          const SizedBox(height: AppSizes.sm),
          Text(
            '"$_query" için sonuç bulunamadı',
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
