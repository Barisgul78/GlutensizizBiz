import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: kBackground,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: const ColorScheme.light(
          primary: kPrimary,
          primaryContainer: kPrimaryContainer,
          onPrimary: kOnPrimary,
          onPrimaryContainer: kOnPrimaryContainer,
          surface: kSurface,
          onSurface: kOnSurface,
          onSurfaceVariant: kOnSurfaceVariant,
          secondary: kSecondary,
          error: kError,
          errorContainer: kErrorContainer,
          onErrorContainer: kOnErrorContainer,
          outline: kOutline,
          outlineVariant: kOutlineVariant,
          inverseSurface: kInverseSurface,
          onInverseSurface: kInverseOnSurface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(color: kOnSurface),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: kSurfaceContainerLow,
          indicatorColor: kSurfaceContainerHigh,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStatePropertyAll(
            IconThemeData(color: kOnSurfaceVariant),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kInverseSurface,
          contentTextStyle: GoogleFonts.sourceSans3(
            color: kInverseOnSurface,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: kSurfaceContainerHigh,
          selectedColor: kPrimary,
          labelStyle: const TextStyle(color: kOnSurface),
          side: const BorderSide(color: kOutlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
}
