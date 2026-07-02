import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// İpucu/rehber kartlarında kullanılan kategori rozeti.
/// filled=true → dolu (kPrimary/kOnPrimary), filled=false → açık chip (kPrimary %12 alpha).
class CategoryBadge extends StatelessWidget {
  final String label;
  final bool filled;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const CategoryBadge({
    super.key,
    required this.label,
    this.filled = true,
    this.padding = const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2, vertical: AppSizes.xs),
    this.fontSize = AppSizes.fontSm,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? kPrimary : kPrimary.withValues(alpha: 0.12);
    final fg = filled ? kOnPrimary : kPrimary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
