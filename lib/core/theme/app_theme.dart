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
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: kSurfaceContainerLow,
          indicatorColor: kSurfaceContainerHigh,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: const WidgetStatePropertyAll(
            IconThemeData(color: kOnSurfaceVariant),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.plusJakartaSans(
              color: selected ? kOnSurface : kOnSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kInverseSurface,
          contentTextStyle: GoogleFonts.sourceSans3(
            color: kInverseOnSurface,
            fontWeight: FontWeight.w500,
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
