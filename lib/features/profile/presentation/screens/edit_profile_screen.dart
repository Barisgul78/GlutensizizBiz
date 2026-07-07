import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/services/profile_service.dart';
import '../widgets/profile_ui.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _adCtrl = TextEditingController();
  final _soyadCtrl = TextEditingController();
  final _kullaniciAdiCtrl = TextEditingController();
  final _telefonCtrl = TextEditingController();
  final _sehirCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _currentUsername = '';
  bool _loading = true;
  bool _saving = false;
  bool _emailVerified = false;
  bool _sendingVerification = false;
  bool _checkingVerification = false;

  @override
  void initState() {
    super.initState();
    _emailVerified = AuthService.currentUser?.emailVerified ?? false;
    _emailCtrl.text = AuthService.currentUser?.email ?? '';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = AuthService.currentUserId;
    if (uid != null) {
      final doc = await ProfileService.getUser(uid);
      final data = doc.data();
      final username = data?['kullaniciAdi'] as String? ?? '';
      if (mounted) {
        setState(() {
          _adCtrl.text = data?['ad'] as String? ?? '';
          _soyadCtrl.text = data?['soyad'] as String? ?? '';
          _currentUsername = username;
          _kullaniciAdiCtrl.text = username;
          _loading = false;
        });
      }
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _soyadCtrl.dispose();
    _kullaniciAdiCtrl.dispose();
    _telefonCtrl.dispose();
    _sehirCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _sendingVerification = true);
    try {
      await AuthService.sendEmailVerification();
      if (!mounted) return;
      showInfoSnackBar(context, 'Doğrulama e-postası gönderildi, gelen kutunu kontrol et.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, AuthService.errorMessage(e.code));
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _sendingVerification = false);
    }
  }

  Future<void> _refreshVerificationStatus() async {
    setState(() => _checkingVerification = true);
    try {
      final verified = await AuthService.reloadAndCheckEmailVerified();
      if (!mounted) return;
      setState(() => _emailVerified = verified);
      showInfoSnackBar(
        context,
        verified ? 'E-postan doğrulanmış! 🎉' : 'Henüz doğrulanmamış görünüyor.',
      );
    } finally {
      if (mounted) setState(() => _checkingVerification = false);
    }
  }

  Future<void> _save() async {
    final ad = _adCtrl.text.trim();
    final kullaniciAdi = _kullaniciAdiCtrl.text.trim();
    if (ad.isEmpty || kullaniciAdi.isEmpty) {
      showErrorSnackBar(context, 'Ad ve kullanıcı adı boş bırakılamaz.');
      return;
    }

    setState(() => _saving = true);
    try {
      // Not: Telefon/Şehir henüz Firestore şemasında yok, bilinçli olarak kaydedilmiyor.
      await AuthService.updateProfileBasics(
        ad: ad,
        soyad: _soyadCtrl.text.trim(),
        currentUsername: _currentUsername,
        newUsername: kullaniciAdi,
      );
      if (!mounted) return;
      showInfoSnackBar(context, 'Değişiklikler kaydedildi.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('kullanici-adi-alinmis')
          ? 'Bu kullanıcı adı zaten alınmış.'
          : 'Değişiklikler kaydedilemedi. Lütfen tekrar deneyin.';
      showErrorSnackBar(context, message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kPrimary))
            : Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(user),
                          _section('KİŞİSEL BİLGİLER', Column(
                            children: [
                              _ProfileField(
                                icon: Icons.person_outline,
                                iconBgColor: kPastelGreen,
                                label: 'Ad',
                                controller: _adCtrl,
                              ),
                              sectionDivider(),
                              _ProfileField(
                                icon: Icons.person_outline,
                                iconBgColor: kPastelGreen,
                                label: 'Soyad',
                                controller: _soyadCtrl,
                              ),
                              sectionDivider(),
                              _ProfileField(
                                icon: Icons.alternate_email,
                                iconBgColor: kPastelBlue,
                                label: 'Kullanıcı Adı',
                                controller: _kullaniciAdiCtrl,
                              ),
                            ],
                          )),
                          const SizedBox(height: 24),
                          _section('İLETİŞİM BİLGİLERİ', Column(
                            children: [
                              _ProfileField(
                                icon: Icons.mail_outline,
                                iconBgColor: kPastelOrange,
                                label: 'E-posta',
                                controller: _emailCtrl,
                                readOnly: true,
                                trailing: _verifiedBadge(_emailVerified),
                              ),
                                if (!_emailVerified) _buildVerificationActions(),
                                sectionDivider(),
                              _ProfileField(
                                icon: Icons.call_outlined,
                                iconBgColor: kPastelBlue,
                                label: 'Telefon',
                                controller: _telefonCtrl,
                                hint: 'Telefon ekle...',
                                keyboardType: TextInputType.phone,
                                trailing: _optionalBadge(),
                              ),
                            ],
                          )),
                          const SizedBox(height: 24),
                          _section('KONUM', _ProfileField(
                            icon: Icons.location_on_outlined,
                            iconBgColor: kPastelOrange,
                            label: 'Şehir',
                            controller: _sehirCtrl,
                            hint: 'Şehir ekle...',
                            trailing: _optionalBadge(),
                          )),
                          const SizedBox(height: 24),
                          Container(
                            decoration: cardDecoration(),
                            child: tappableIconRow(
                              context,
                              icon: Icons.lock_outline,
                              iconBgColor: kSurfaceContainerHigh,
                              title: 'Şifre Değiştir',
                              subtitle: 'Hesap güvenliğini güncelle',
                              onTap: () => showInfoSnackBar(context, 'Yakında'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Değişiklikleri Kaydet',
                            loading: _saving,
                            onPressed: _save,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Başlık + kart iskeleti — Kişisel/İletişim/Konum bölümlerinde tekrar eder.
  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        const SizedBox(height: 10),
        Container(decoration: cardDecoration(), child: child),
      ],
    );
  }

  Widget _buildVerificationActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _VerificationActionButton(
            loading: _sendingVerification,
            label: 'Doğrulama Maili Gönder',
            color: kPrimary,
            onPressed: _sendVerificationEmail,
          ),
          const SizedBox(width: 16),
          _VerificationActionButton(
            loading: _checkingVerification,
            label: 'Yenile',
            icon: Icons.refresh,
            color: kOnSurfaceVariant,
            onPressed: _refreshVerificationStatus,
          ),
        ],
      ),
    );
  }

  Widget _optionalBadge() => const _Badge(text: 'Opsiyonel', color: kBadgeInfo);

  Widget _verifiedBadge(bool verified) => _Badge(
        text: verified ? 'Doğrulandı' : 'Doğrulanmadı',
        color: verified ? kBadgeSuccess : kBadgeDanger,
      );

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 12, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: kOnSurface),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Hesap Bilgileri',
              style: GoogleFonts.plusJakartaSans(
                color: kOnSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials(user?.displayName),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => showInfoSnackBar(context, 'Yakında'),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: kSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showInfoSnackBar(context, 'Yakında'),
              child: Text(
                'Fotoğraf Değiştir',
                style: GoogleFonts.plusJakartaSans(
                  color: kPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'JPG veya PNG, max 5MB',
              style: GoogleFonts.sourceSans3(
                color: kOnSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Görseldeki kart-içi alan satırı: sol ikon dairesi + üstte etiket + altta input.
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.keyboardType,
    this.trailing,
  });

  final IconData icon;
  final Color iconBgColor;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: keyboardType,
                  style: GoogleFonts.plusJakartaSans(
                    color: readOnly ? kOnSurfaceVariant : kOnSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: kOnSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.sourceSans3(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// E-posta doğrulama satırındaki "Gönder"/"Yenile" butonları — ikisi de
// aynı loading-spinner + metin/ikon desenini paylaşır.
class _VerificationActionButton extends StatelessWidget {
  const _VerificationActionButton({
    required this.loading,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
  });

  final bool loading;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: loading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                      color: color, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
    );
  }
}
