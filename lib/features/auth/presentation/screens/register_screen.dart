import 'dart:async';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/validators.dart';
import '../../data/services/auth_service.dart';

enum _UsernameStatus { idle, invalid, checking, available, taken }

final _usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adCtrl = TextEditingController();
  final _soyadCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();

  DateTime? _birthDate;
  bool _loading = false;
  bool _showPass = false;
  bool _showConfirm = false;
  _UsernameStatus _usernameStatus = _UsernameStatus.idle;
  Timer? _debounce;

  @override
  void dispose() {
    _adCtrl.dispose();
    _soyadCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _birthDateCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final username = value.trim().toLowerCase();
    if (username.isEmpty) {
      setState(() => _usernameStatus = _UsernameStatus.idle);
      return;
    }
    if (!_usernameRegex.hasMatch(username)) {
      setState(() => _usernameStatus = _UsernameStatus.invalid);
      return;
    }
    setState(() => _usernameStatus = _UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 500), () => _checkUsername(username));
  }

  Future<void> _checkUsername(String username) async {
    final taken = await AuthService.isUsernameTaken(username);
    if (!mounted) return;
    // Kullanıcı bu arada yazmaya devam ettiyse eski sonucu uygulama
    if (_usernameCtrl.text.trim().toLowerCase() != username) return;
    setState(() {
      _usernameStatus = taken ? _UsernameStatus.taken : _UsernameStatus.available;
    });
  }

  Widget? _usernameSuffixIcon() {
    switch (_usernameStatus) {
      case _UsernameStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _UsernameStatus.available:
        return const Icon(Icons.check_circle, color: kBadgeSuccess);
      case _UsernameStatus.taken:
      case _UsernameStatus.invalid:
        return const Icon(Icons.cancel, color: kError);
      case _UsernameStatus.idle:
        return null;
    }
  }

  void _pickBirthDate() {
    final now = DateTime.now();
    BottomPicker<DateTime>.date(
      headerBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Doğum Tarihi',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: kOnSurface,
          ),
        ),
      ),
      initialDateTime: DateTime(now.year - 18, now.month, now.day),
      minDateTime: DateTime(1900),
      maxDateTime: now,
      onSubmit: (date) {
        if (date == null) return;
        setState(() {
          _birthDate = date;
          _birthDateCtrl.text =
              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        });
      },
      buttonSingleColor: kPrimary,
    ).show(context);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        ad: _adCtrl.text.trim(),
        soyad: _soyadCtrl.text.trim(),
        birthDate: _birthDate!,
        username: _usernameCtrl.text.trim().toLowerCase(),
      );
      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, AuthService.errorMessage(e.code));
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Ad
                AppTextField(
                  controller: _adCtrl,
                  label: 'Ad',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, label: 'Ad'),
                ),
                const SizedBox(height: 14),

                // Soyad
                AppTextField(
                  controller: _soyadCtrl,
                  label: 'Soyad',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, label: 'Soyad'),
                ),
                const SizedBox(height: 14),

                // Kullanıcı Adı
                AppTextField(
                  controller: _usernameCtrl,
                  label: 'Kullanıcı Adı',
                  icon: Icons.alternate_email_rounded,
                  onChanged: _onUsernameChanged,
                  suffixIcon: _usernameSuffixIcon(),
                  validator: (v) {
                    final username = v?.trim().toLowerCase() ?? '';
                    if (username.isEmpty) return 'Kullanıcı adı gerekli.';
                    if (!_usernameRegex.hasMatch(username)) {
                      return '3-20 karakter, sadece harf/rakam/_ kullanılabilir.';
                    }
                    if (_usernameStatus == _UsernameStatus.checking) {
                      return 'Kullanılabilirlik kontrol ediliyor...';
                    }
                    if (_usernameStatus == _UsernameStatus.taken) {
                      return 'Bu kullanıcı adı alınmış.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // E-posta
                AppTextField(
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
                AppTextField(
                  controller: _passCtrl,
                  label: 'Şifre',
                  icon: Icons.lock_outline_rounded,
                  obscure: !_showPass,
                  suffixIcon: AuthFieldToggleVisibility(
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
                AppTextField(
                  controller: _confirmCtrl,
                  label: 'Şifre Tekrar',
                  icon: Icons.lock_outline_rounded,
                  obscure: !_showConfirm,
                  suffixIcon: AuthFieldToggleVisibility(
                    show: _showConfirm,
                    onTap: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Şifreler eşleşmiyor.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Doğum tarihi
                AppTextField(
                  controller: _birthDateCtrl,
                  label: 'Doğum Tarihi',
                  icon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: _pickBirthDate,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Doğum tarihi gerekli.';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Kayıt Ol butonu
                AppButton(
                  label: 'Kayıt Ol',
                  onPressed: _loading ? null : _register,
                  loading: _loading,
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
                          fontWeight: FontWeight.w500,
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
