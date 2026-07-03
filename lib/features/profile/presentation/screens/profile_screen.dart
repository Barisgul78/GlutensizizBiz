import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/date_utils.dart' as du;
import '../../../../../core/utils/string_utils.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/sign_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Üyelik tarihini Türkçe formatla
  String _memberSince() {
    final date = AuthService.currentUser?.metadata.creationTime;
    if (date == null) return '';
    return '${du.formatMonthYear(date)}\'den beri üye';
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignScreen()),
      (_) => false,
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yakında')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isAnonymous = AuthService.isAnonymous;
    final displayName =
        isAnonymous ? 'Misafir' : (user?.displayName ?? 'Kullanıcı');
    final email = isAnonymous ? 'Misafir hesabı' : (user?.email ?? '');

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildAvatar(displayName, email),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(context),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSectionTitle('SAĞLIK PROFİLİM'),
                    const SizedBox(height: 10),
                    _buildHealthProfile(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('ROZETLERİM'),
                    const SizedBox(height: 10),
                    _buildBadgesGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('UYGULAMA'),
                    const SizedBox(height: 10),
                    _buildSettingsGroup([
                      const _SettingsItem(
                        icon: Icons.notifications_outlined,
                        iconBgColor: kSurfaceContainerHigh,
                        title: 'Bildirim Ayarları',
                        subtitle: 'Günlük ipucu, ürün değişiklikleri',
                      ),
                      const _SettingsItem(
                        icon: Icons.help_outline,
                        iconBgColor: kSurfaceContainerHigh,
                        title: 'Yardım ve Destek',
                        subtitle: 'SSS, iletişim',
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildLogoutCard(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Profil',
              style: GoogleFonts.plusJakartaSans(
                color: kOnSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () => _showSoon(context),
                child: const Icon(Icons.settings_outlined,
                    color: kOnSurfaceVariant, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String displayName, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials(AuthService.currentUser?.displayName),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: kSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: GoogleFonts.plusJakartaSans(
              color: kOnSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style:
                GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 14),
          ),
          if (_memberSince().isNotEmpty) ...[
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.edit_outlined, 'Profili\nDüzenle'),
      (Icons.badge_outlined, 'Sağlık\nKartım'),
      (Icons.military_tech_outlined, 'Rozetlerim'),
      (Icons.settings_outlined, 'Ayarlar'),
    ];
    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _showSoon(context),
                    child: Container(
                      height: 88,
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kOutlineVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(a.$1, color: kPrimary, size: 20),
                          const SizedBox(height: 6),
                          Text(
                            a.$2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: GoogleFonts.sourceSans3(
                              color: kOnSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHealthProfile() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutlineVariant),
      ),
      child: Column(
        children: [
          _buildHealthRow(
            icon: Icons.eco_outlined,
            iconBgColor: kPastelGreen,
            title: 'Glutensiz Durumum',
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kPrimaryFixed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Çölyak Hastası',
                style: GoogleFonts.sourceSans3(
                  color: kPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: kOutlineVariant.withValues(alpha: 0.6)),
          _buildHealthRow(
            icon: Icons.calendar_today_outlined,
            iconBgColor: kPastelYellow,
            title: 'Tanı Yılım',
            subtitle: '2019 - 5 yıldır çölyakla yaşıyorsun',
          ),
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: kOutlineVariant.withValues(alpha: 0.6)),
          _buildHealthRow(
            icon: Icons.location_on_outlined,
            iconBgColor: kPastelBlue,
            title: 'Şehrim',
            subtitle: 'İstanbul - Belediye yardımları aktif',
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant, fontSize: 12),
                  ),
                ],
                if (child != null) child,
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kOutlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final badges = [
      (
        Icons.center_focus_strong_outlined,
        'İlk Tarama',
        '47 ürün tarandı',
        kPastelGreen,
        true
      ),
      (
        Icons.explore_outlined,
        'Kaşif',
        '12 mekan keşfedildi',
        kPastelOrange,
        true
      ),
      (
        Icons.menu_book_outlined,
        'Rehber Kurdu',
        '23 makale okundu',
        kPastelBlue,
        true
      ),
      (
        Icons.lock_outline,
        'Tarif Ustası',
        '5 tarif ekle',
        kSurfaceContainerHigh,
        false
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: badges.map((b) {
        final (icon, title, subtitle, bgColor, unlocked) = b;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kOutlineVariant),
          ),
          child: Opacity(
            opacity: unlocked ? 1 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: bgColor, shape: BoxShape.circle),
                      child: Icon(icon, color: kPrimary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: kOnSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsGroup(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutlineVariant),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildSettingsRow(item),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: kOutlineVariant.withValues(alpha: 0.6),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsRow(_SettingsItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kOutlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _signOut(context),
      child: Container(
        decoration: BoxDecoration(
          color: kErrorContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kError.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kError.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: kError, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                'Çıkış Yap',
                style: GoogleFonts.plusJakartaSans(
                  color: kError,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? subtitle;

  const _SettingsItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
  });
}
