import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/routing/main_shell.dart';
import '../../data/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(AuthService.errorMessage(e.code));
    } catch (_) {
      if (!mounted) return;
      _showError('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Hesap Oluştur',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kOnSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Glutensiz dünyaya adımını at.',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Ad Soyad
                _AuthField(
                  controller: _nameCtrl,
                  label: 'Ad Soyad',
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ad soyad gerekli.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // E-posta
                _AuthField(
                  controller: _emailCtrl,
                  label: 'E-posta',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'E-posta gerekli.';
                    if (!v.contains('@')) return 'Geçersiz e-posta adresi.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Şifre
                _AuthField(
                  controller: _passCtrl,
                  label: 'Şifre',
                  icon: Icons.lock_outline_rounded,
                  obscure: !_showPass,
                  suffixIcon: _ToggleVisibility(
                    show: _showPass,
                    onTap: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifre gerekli.';
                    if (v.length < 6) return 'Şifre en az 6 karakter olmalı.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Şifre tekrar
                _AuthField(
                  controller: _confirmCtrl,
                  label: 'Şifre Tekrar',
                  icon: Icons.lock_outline_rounded,
                  obscure: !_showConfirm,
                  suffixIcon: _ToggleVisibility(
                    show: _showConfirm,
                    onTap: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Şifreler eşleşmiyor.';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Kayıt Ol butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _loading ? null : _register,
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Kayıt Ol',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Zaten hesabın var mı?
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Zaten hesabın var mı?  ',
                        style: GoogleFonts.sourceSans3(
                          color: kOnSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Giriş Yap',
                          style: GoogleFonts.plusJakartaSans(
                            color: kPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ortak form alanı
// ─────────────────────────────────────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.sourceSans3(color: kOnSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.sourceSans3(color: kOnSurfaceVariant),
        prefixIcon: Icon(icon, color: kOnSurfaceVariant, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kOutlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Şifre görünürlük butonu
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleVisibility extends StatelessWidget {
  const _ToggleVisibility({required this.show, required this.onTap});
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
