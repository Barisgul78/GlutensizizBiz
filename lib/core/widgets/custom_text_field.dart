import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

// Uygulamada kullanılan ortak metin giriş alanı
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofillHints: autofillHints,
      style: GoogleFonts.sourceSans3(color: kOnSurface, fontSize: AppSizes.fontLg - 1),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.sourceSans3(color: kOnSurfaceVariant),
        prefixIcon: icon != null
            ? Icon(icon, color: kOnSurfaceVariant, size: AppSizes.iconSm + 4)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
          borderSide: const BorderSide(color: kOutlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
          borderSide: const BorderSide(color: kError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
      ),
    );
  }
}
