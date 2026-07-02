import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/sign_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Üyelik tarihini Türkçe formatla
  String _memberSince() {
    final date = AuthService.currentUser?.metadata.creationTime;
    if (date == null) return '';
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${months[date.month]} ${date.year}\'den beri üye';
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isAnonymous = AuthService.isAnonymous;
    final displayName = isAnonymous ? 'Misafir' : (user?.displayName ?? 'Kullanıcı');
    final email = isAnonymous ? 'Misafir hesabı' : (user?.email ?? '');

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildAvatar(displayName, email),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSettingsGroup([
                      const _SettingsItem(
                        icon: Icons.person_outline,
                        iconBgColor: kSurfaceContainerHigh,
                        title: 'Kişisel Bilgiler',
                        subtitle: 'Adınızı, e-postanızı ve şifrenizi güncelleyin',
                      ),
                      const _SettingsItem(
                        icon: Icons.restaurant_menu_outlined,
                        iconBgColor: kSecondaryFixed,
                        title: 'Beslenme Tercihleri',
                        subtitle: null,
                        tags: ['ÇÖLYAK', 'VEGAN'],
                      ),
                      const _SettingsItem(
                        icon: Icons.notifications_outlined,
                        iconBgColor: kSurfaceContainerHigh,
                        title: 'Bildirim Ayarları',
                        subtitle: 'Yeni tarifler ve yerel mekanlar için uyarıları yönetin',
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSingleCard(
                      icon: Icons.help_outline,
                      iconBgColor: kSurfaceContainerHigh,
                      title: 'Yardım & Destek',
                    ),
                    const SizedBox(height: 12),
                    _buildLogoutCard(context),
                    const SizedBox(height: 32),
                    const Icon(Icons.eco_outlined,
                        color: kOutlineVariant, size: 28),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Sol — avatar (küçük)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary,
            ),
            child: Center(
              child: Text(
                initials(AuthService.currentUser?.displayName),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Profil',
            style: GoogleFonts.plusJakartaSans(
              color: kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kSurfaceContainerHigh,
            ),
            child: const Icon(Icons.notifications_outlined,
                color: kOnSurfaceVariant, size: 20),
          ),
        ],
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
            style: GoogleFonts.sourceSans3(
                color: kOnSurfaceVariant, fontSize: 14),
          ),
          if (_memberSince().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _memberSince(),
              style: GoogleFonts.sourceSans3(
                color: kOnSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
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
                if (item.tags != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: item.tags!
                        .map((tag) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: kPrimaryFixed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        .toList(),
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

  Widget _buildSingleCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutlineVariant),
      ),
      child: _buildSettingsRow(_SettingsItem(
        icon: icon,
        iconBgColor: iconBgColor,
        title: title,
      )),
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
  final List<String>? tags;

  const _SettingsItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.tags,
  });
}
