import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/sign_screen.dart';
import '../widgets/health_journey_card.dart';
import '../widgets/stats_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _quickActions = [
    _QuickAction(Icons.edit_outlined, 'Profili\nDüzenle'),
    _QuickAction(Icons.badge_outlined, 'Sağlık\nKartım'),
    _QuickAction(Icons.military_tech_outlined, 'Rozetlerim'),
    _QuickAction(Icons.settings_outlined, 'Ayarlar'),
  ];

  static const _badges = [
    _Badge(Icons.center_focus_strong_outlined, 'İlk Tarama', '47 ürün tarandı',
        kPastelGreen, true),
    _Badge(Icons.explore_outlined, 'Kaşif', '12 mekan keşfedildi',
        kPastelOrange, true),
    _Badge(Icons.menu_book_outlined, 'Rehber Kurdu', '23 makale okundu',
        kPastelBlue, true),
    _Badge(Icons.lock_outline, 'Tarif Ustası', '5 tarif ekle',
        kSurfaceContainerHigh, false),
  ];

  Future<void> _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignScreen()),
      (_) => false,
    );
  }

  static BoxDecoration _cardDecoration({
    Color color = kOnPrimary,
    Color? borderColor,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor != null ? Border.all(color: borderColor) : null,
      boxShadow: borderColor == null
          ? [
              BoxShadow(
                color: kOnSurface.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  static Widget _sectionDivider() => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: kOutlineVariant.withValues(alpha: 0.6),
      );

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
              _buildAvatar(user, displayName, email),
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
                    const HealthJourneyCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('ROZETLERİM'),
                    const SizedBox(height: 10),
                    _buildBadgesGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('İSTATİSTİKLERİM'),
                    const SizedBox(height: 10),
                    const StatsSection(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User? user, String displayName, String email) {
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
                    initials(user?.displayName),
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
            style: GoogleFonts.sourceSans3(
                color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
          ),
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
    return Row(
      children: _quickActions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => showInfoSnackBar(context, 'Yakında'),
                    child: Container(
                      height: 88,
                      decoration: _cardDecoration(radius: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(a.icon, color: kPrimary, size: 20),
                          const SizedBox(height: 6),
                          Text(
                            a.label,
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

  // Sağlık profili satırı ve ayarlar satırı için ortak ikon+başlık+alt yazı düzeni
  Widget _buildIconRow({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showChevron = true,
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
                        color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (trailing != null) trailing,
              ],
            ),
          ),
          if (showChevron)
            const Icon(Icons.chevron_right, color: kOutlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: _badges.map((b) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Opacity(
            opacity: b.unlocked ? 1 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: b.bgColor, shape: BoxShape.circle),
                      child: Icon(b.icon, color: kPrimary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b.title,
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
                  b.subtitle,
                  style: GoogleFonts.sourceSans3(
                      color: kOnSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500),
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
      decoration: _cardDecoration(),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildIconRow(
                icon: item.icon,
                iconBgColor: item.iconBgColor,
                title: item.title,
                subtitle: item.subtitle,
              ),
              if (index < items.length - 1) _sectionDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _signOut(context),
      child: Container(
        decoration: _cardDecoration(
          color: kErrorContainer,
          borderColor: kError.withValues(alpha: 0.3),
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

class _QuickAction {
  final IconData icon;
  final String label;

  const _QuickAction(this.icon, this.label);
}

class _Badge {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final bool unlocked;

  const _Badge(
      this.icon, this.title, this.subtitle, this.bgColor, this.unlocked);
}
