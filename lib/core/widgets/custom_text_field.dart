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

  static OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
        borderSide: width == 0
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );

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
      style: GoogleFonts.sourceSans3(color: kOnSurface, fontSize: AppSizes.fontLg - 1, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontWeight: FontWeight.w500),
        prefixIcon: icon != null
            ? Icon(icon, color: kOnSurfaceVariant, size: AppSizes.iconSm + 4)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: _border(Colors.transparent, 0),
        enabledBorder: _border(kOutlineVariant, 1),
        focusedBorder: _border(kPrimary, 1.5),
        errorBorder: _border(kError, 1),
        focusedErrorBorder: _border(kError, 1.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
      ),
    );
  }
}

// Şifre alanlarında göster/gizle ikonu — AppTextField suffixIcon'u olarak kullanılır
class AuthFieldToggleVisibility extends StatelessWidget {
  const AuthFieldToggleVisibility({super.key, required this.show, required this.onTap});
  final bool show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: kOnSurfaceVariant,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}
