import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/utils/date_utils.dart' as du;
import '../../data/models/tip.dart';
import '../../data/services/tips_service.dart';
import '../widgets/category_badge.dart';
import '../widgets/tip_image.dart';
import 'tip_detail_screen.dart';

class TipsListScreen extends StatelessWidget {
  const TipsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = TipsService.getAll();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kOnSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Günün Bilgisi',
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.md,
        ),
        itemCount: tips.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
        itemBuilder: (context, i) => _TipListCard(
          tip: tips[i],
          formattedDate: du.formatDate(tips[i].date),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TipDetailScreen(tip: tips[i])),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Liste öğesi kartı
// ─────────────────────────────────────────────────────────────────────────────
class _TipListCard extends StatelessWidget {
  const _TipListCard({
    required this.tip,
    required this.formattedDate,
    required this.onTap,
  });

  final Tip tip;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurfaceContainer,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSizes.radiusLg),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: TipImage(asset: tip.imageAsset),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryBadge(
                      label: tip.category,
                      filled: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: 3,
                      ),
                      fontSize: AppSizes.fontXs + 1,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      tip.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: kOnSurface,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      '${tip.author}  ·  $formattedDate',
                      style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant,
                        fontSize: AppSizes.fontXs + 1,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSizes.sm),
              child: Icon(Icons.chevron_right_rounded,
                  color: kOnSurfaceVariant, size: AppSizes.iconMd),
            ),
          ],
        ),
      ),
    );
  }
}
