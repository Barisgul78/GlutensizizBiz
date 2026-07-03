import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as du;
import '../../../../core/utils/snackbars.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/services/profile_service.dart';
import 'diagnosis_date_picker.dart';

const _milestones = [100, 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 7500, 10000];

// Tanı yılına göre gün sayacı, yıl ilerlemesi ve milestone hesaplaması
class _HealthJourneyStats {
  final int totalDays;
  final int completedYears;
  final int nextYearNumber;
  final int daysToNextYear;
  final int totalDaysAtNextYear;
  final double yearProgress;
  final int? lastMilestone;

  const _HealthJourneyStats({
    required this.totalDays,
    required this.completedYears,
    required this.nextYearNumber,
    required this.daysToNextYear,
    required this.totalDaysAtNextYear,
    required this.yearProgress,
    required this.lastMilestone,
  });

  factory _HealthJourneyStats.calculate(DateTime diagnosisDate) {
    final start = diagnosisDate;
    final now = DateTime.now();
    final totalDays = now.difference(start).inDays;

    var completed = 0;
    while (!DateTime(start.year + completed + 1, start.month, 1).isAfter(now)) {
      completed++;
    }
    final yearStart = DateTime(start.year + completed, start.month, 1);
    final yearEnd = DateTime(start.year + completed + 1, start.month, 1);
    final daysInYear = yearEnd.difference(yearStart).inDays;
    final daysIntoYear = now.difference(yearStart).inDays;

    int? lastMilestone;
    for (final m in _milestones) {
      if (totalDays >= m) lastMilestone = m;
    }

    return _HealthJourneyStats(
      totalDays: totalDays,
      completedYears: completed,
      nextYearNumber: completed + 1,
      daysToNextYear: yearEnd.difference(now).inDays,
      totalDaysAtNextYear: yearEnd.difference(start).inDays,
      yearProgress: daysInYear == 0 ? 0 : daysIntoYear / daysInYear,
      lastMilestone: lastMilestone,
    );
  }
}

// Sağlık Profilim kartı: tanı yılı girilmemişse boş durum, girilmişse gün sayacı gösterir
class HealthJourneyCard extends StatelessWidget {
  const HealthJourneyCard({super.key});

  BoxDecoration get _decoration => BoxDecoration(
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

  Future<void> _onAddPressed(BuildContext context) async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      showInfoSnackBar(context, 'Tanı yılını eklemek için giriş yapmanız gerekiyor.');
      return;
    }
    final date = await showDiagnosisDatePicker(context);
    if (date != null) {
      await ProfileService.setDiagnosisDate(userId, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUserId;

    if (userId == null) {
      return _EmptyState(decoration: _decoration, onAddPressed: () => _onAddPressed(context));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ProfileService.userStream(userId),
      builder: (context, snapshot) {
        final timestamp = snapshot.data?.data()?['tani_tarihi'] as Timestamp?;

        if (timestamp == null) {
          return _EmptyState(decoration: _decoration, onAddPressed: () => _onAddPressed(context));
        }

        final diagnosisDate = timestamp.toDate();
        final stats = _HealthJourneyStats.calculate(diagnosisDate);
        return _FilledState(decoration: _decoration, diagnosisDate: diagnosisDate, stats: stats);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.decoration, required this.onAddPressed});

  final BoxDecoration decoration;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: decoration.copyWith(
        border: Border.all(color: kOutlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: kPastelGreen, shape: BoxShape.circle),
            child: const Icon(Icons.eco_outlined, color: kPrimary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Çölyak Yolculuğun',
            style: GoogleFonts.plusJakartaSans(
              color: kOnSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tanı yılını ekle, glutensiz yolculuğunun kaç gündür sürdüğünü birlikte görelim!',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAddPressed,
            style: FilledButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: kOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Tanı Yılımı Ekle',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledState extends StatelessWidget {
  const _FilledState({
    required this.decoration,
    required this.diagnosisDate,
    required this.stats,
  });

  final BoxDecoration decoration;
  final DateTime diagnosisDate;
  final _HealthJourneyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: kPastelGreen, shape: BoxShape.circle),
                child: const Icon(Icons.eco_outlined, color: kPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Çölyak Yolculuğun',
                      style: GoogleFonts.plusJakartaSans(
                        color: kOnSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Tanı tarihi: ${du.formatMonthYear(diagnosisDate)}',
                      style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${stats.totalDays}',
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                TextSpan(
                  text: ' gün glutensiz 💪',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: stats.yearProgress.clamp(0, 1),
            backgroundColor: kSurfaceContainerHigh,
            progressColor: kPrimary,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.completedYears}. yıl',
                style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${stats.nextYearNumber}. yıla ${stats.daysToNextYear} gün kaldı',
                style: GoogleFonts.sourceSans3(
                  color: kOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: kOutlineVariant),
          _statRow(
            icon: Icons.emoji_events_outlined,
            label: 'Son milestone',
            value: stats.lastMilestone != null ? '${stats.lastMilestone} gün 🏆' : '-',
          ),
          const SizedBox(height: 10),
          _statRow(
            icon: Icons.flag_outlined,
            label: 'Sonraki hedef',
            value: '${stats.nextYearNumber}. yıl → ${stats.totalDaysAtNextYear} gün',
          ),
        ],
      ),
    );
  }

  Widget _statRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: kOnSurfaceVariant, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryFixed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: GoogleFonts.sourceSans3(
              color: kPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
