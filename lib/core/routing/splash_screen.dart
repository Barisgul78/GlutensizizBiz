import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';
import '../localization/app_strings.dart';

// Uygulama açılışında kısa süre gösterilen logo ekranı
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: AppSizes.iconLg + 8,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              AppStrings.appName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontDisplay,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              AppStrings.appSlogan,
              style: GoogleFonts.sourceSans3(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
