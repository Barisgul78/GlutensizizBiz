import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../auth/data/services/auth_service.dart';
import '../widgets/health_journey_card.dart';
import '../widgets/profile_ui.dart';
import '../widgets/stats_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _quickActions = [
    _QuickAction(Icons.edit_outlined, 'Profili\nDüzenle'),
    _QuickAction(Icons.badge_outlined, 'Sağlık\nKartım'),
    _QuickAction(Icons.military_tech_outlined, 'Rozetlerim'),
  ];

  static const _badges = [
    _Badge(
      icon: Icons.center_focus_strong_outlined,
      title: 'İlk Tarama',
      subtitle: '47 ürün tarandı',
      bgColor: kPastelGreen,
      unlocked: true,
    ),
    _Badge(
      icon: Icons.explore_outlined,
      title: 'Kaşif',
      subtitle: '12 mekan keşfedildi',
      bgColor: kPastelOrange,
      unlocked: true,
    ),
    _Badge(
      icon: Icons.menu_book_outlined,
      title: 'Rehber Kurdu',
      subtitle: '23 makale okundu',
      bgColor: kPastelBlue,
      unlocked: true,
    ),
    _Badge(
      icon: Icons.lock_outline,
      title: 'Tarif Ustası',
      subtitle: '5 tarif ekle',
      bgColor: kSurfaceContainerHigh,
      unlocked: false,
    ),
  ];

  Future<void> _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    context.go('/sign');
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
                    sectionTitle('SAĞLIK PROFİLİM'),
                    const SizedBox(height: 10),
                    const HealthJourneyCard(),
                    const SizedBox(height: 24),
                    sectionTitle('ROZETLERİM'),
                    const SizedBox(height: 10),
                    _buildBadgesGrid(),
                    const SizedBox(height: 24),
                    sectionTitle('İSTATİSTİKLERİM'),
                    const SizedBox(height: 10),
                    const StatsSection(),
                    const SizedBox(height: 24),
                    sectionTitle('UYGULAMA'),
                    const SizedBox(height: 10),
                    _buildSettingsGroup(context, [
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
        height: 48,
        child: Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Center(
                child: Text(
                  'Profil',
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: kOnSurface),
              onPressed: () => context.push('/settings'),
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
                      decoration: cardDecoration(radius: 14),
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
          decoration: cardDecoration(),
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

  Widget _buildSettingsGroup(BuildContext context, List<_SettingsItem> items) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              IconRow(
                icon: item.icon,
                iconBgColor: item.iconBgColor,
                title: item.title,
                subtitle: item.subtitle,
              ),
              if (index < items.length - 1) sectionDivider(),
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
        decoration: cardDecoration(
          color: kErrorContainer,
          borderColor: kError.withValues(alpha: 0.3),
        ),
        child: IconRow(
          icon: Icons.logout,
          iconBgColor: kError.withValues(alpha: 0.12),
          title: 'Çıkış Yap',
          showChevron: false,
          titleColor: kError,
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

  const _Badge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.unlocked,
  });
}
