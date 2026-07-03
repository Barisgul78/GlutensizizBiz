import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/services/profile_service.dart';

const _productBadgeSteps = [50, 100, 150, 200, 300, 400, 500, 750, 1000];

BoxDecoration _cardDecoration() => BoxDecoration(
      color: kOnPrimary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: kOnSurface.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

// Profil "İSTATİSTİKLERİM" bölümü: giriş serisi + 4 sayaç kutusu + rozet ilerlemesi
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUserId;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ProfileService.userStream(userId),
      builder: (context, snapshot) {
        final stats = snapshot.data?.data()?['istatistikler'] as Map<String, dynamic>? ?? {};

        final aranan = stats['aranan_urun_toplam'] as int? ?? 0;
        final aranaBuAy = stats['aranan_urun_bu_ay'] as int? ?? 0;

        final mekanIds = List<String>.from(stats['kesfedilen_mekan_idleri'] as List? ?? const []);
        final mekanBuAy = stats['kesfedilen_mekan_bu_ay'] as int? ?? 0;

        final urunIds = List<String>.from(stats['tiklanan_urun_idleri'] as List? ?? const []);
        final urunBuAy = stats['tiklanan_urun_bu_ay'] as int? ?? 0;

        final okunanMakale = stats['okunan_makale_toplam'] as int? ?? 0;

        final seri = stats['giris_serisi'] as int? ?? 0;
        final rekor = stats['giris_serisi_rekor'] as int? ?? 0;

        final tiklananUrunSayisi = urunIds.length;
        final nextBadge = _productBadgeSteps
            .firstWhere((s) => s > tiklananUrunSayisi, orElse: () => _productBadgeSteps.last);
        final kalan = (nextBadge - tiklananUrunSayisi).clamp(0, nextBadge);
        final badgeProgress = nextBadge == 0 ? 0.0 : tiklananUrunSayisi / nextBadge;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StreakCard(seri: seri, rekor: rekor),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Aranan ürün',
                    value: aranan,
                    thisMonth: aranaBuAy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Keşfedilen mekan',
                    value: mekanIds.length,
                    thisMonth: mekanBuAy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(label: 'Okunan makale', value: okunanMakale, thisMonth: null),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Tıklanan ürün',
                    value: tiklananUrunSayisi,
                    thisMonth: urunBuAy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kalan > 0 ? 'Sonraki rozete $kalan ürün kaldı 🏅' : 'Rozet tamamlandı 🏅',
                    style: GoogleFonts.plusJakartaSans(
                      color: kPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 8,
                    percent: badgeProgress.clamp(0, 1),
                    backgroundColor: kOnPrimary,
                    progressColor: kPrimary,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$tiklananUrunSayisi / $nextBadge ürün tıklandı',
                    style: GoogleFonts.sourceSans3(
                      color: kPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.seri, required this.rekor});

  final int seri;
  final int rekor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: kPastelOrange, shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department_rounded, color: kSecondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giriş Serisi',
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Rekor: $rekor gün',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$seri',
                style: GoogleFonts.plusJakartaSans(
                  color: kSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                'gün',
                style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.thisMonth});

  final String label;
  final int value;
  final int? thisMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: GoogleFonts.plusJakartaSans(
              color: kOnSurface,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          if (thisMonth != null) ...[
            const SizedBox(height: 4),
            Text(
              'Bu ay +$thisMonth',
              style: GoogleFonts.sourceSans3(
                color: kBadgeSuccess,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
