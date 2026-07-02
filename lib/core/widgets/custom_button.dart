import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

// Primary dolu buton — loading ve disabled durumları destekler
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.width = double.infinity,
    this.height = AppSizes.buttonHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = AppSizes.radiusFull,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? kPrimary;
    final fg = foregroundColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: fg,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
      ),
    );
  }
}

// Outlined (kenarlıklı) buton varyantı
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.height = AppSizes.buttonHeight,
    this.borderColor,
    this.textColor,
    this.borderRadius = AppSizes.radiusFull,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? kPrimary;
    final fgColor = textColor ?? kPrimary;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}
