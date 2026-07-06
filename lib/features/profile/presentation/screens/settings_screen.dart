import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/snackbars.dart';
import '../widgets/profile_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text(
          'Ayarlar',
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              sectionTitle('TERCİHLER'),
              const SizedBox(height: 10),
              _buildPreferencesGroup(context),
              const SizedBox(height: 24),
              sectionTitle('HAKKINDA & YASAL'),
              const SizedBox(height: 10),
              _buildAboutSection(context),
              const SizedBox(height: 24),
              sectionTitle('HESAP YÖNETİMİ'),
              const SizedBox(height: 10),
              _buildAccountSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tercihler (hardcoded — gerçek tema/dil geçişi sonraki iş) ────────────────
  Widget _buildPreferencesGroup(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          const IconRow(
            icon: Icons.dark_mode_outlined,
            iconBgColor: kSurfaceContainerHigh,
            title: 'Karanlık Mod',
            subtitle: 'Koyu tema kullan',
            showChevron: false,
            // Henüz bağlı değil — Switch.disabled ile dürüstçe "pasif" gösteriliyor
            trailing: Switch(value: true, onChanged: null),
          ),
          sectionDivider(),
          IconRow(
            icon: Icons.language_outlined,
            iconBgColor: kSurfaceContainerHigh,
            title: 'Dil Seçimi',
            subtitle: 'Uygulama dili',
            showChevron: false,
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'TR', label: Text('TR')),
                ButtonSegment(value: 'EN', label: Text('EN')),
              ],
              selected: const {'TR'},
              onSelectionChanged: null,
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                selectedBackgroundColor: kPrimary,
                selectedForegroundColor: kOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hakkında & Yasal (hardcoded) ──────────────────────────────────────────
  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: kPastelGreen, shape: BoxShape.circle),
                child: const Icon(Icons.eco_outlined, color: kPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GlutensizizBiz',
                      style: GoogleFonts.plusJakartaSans(
                        color: kOnSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Çölyak yaşam rehberi',
                      style: GoogleFonts.sourceSans3(
                        color: kOnSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kBadgeSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v1.0.0',
                  style: GoogleFonts.sourceSans3(
                    color: kBadgeSuccess,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: [
              tappableIconRow(
                context,
                icon: Icons.lock_outline,
                iconBgColor: kSurfaceContainerHigh,
                title: 'Gizlilik Politikası',
                onTap: () => showInfoSnackBar(context, 'Yakında'),
              ),
              sectionDivider(),
              tappableIconRow(
                context,
                icon: Icons.description_outlined,
                iconBgColor: kSurfaceContainerHigh,
                title: 'Kullanım Koşulları',
                onTap: () => showInfoSnackBar(context, 'Yakında'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _socialButton(context, Icons.camera_alt_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _socialButton(context, Icons.close_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _socialButton(context, Icons.smart_display_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _socialButton(context, Icons.mail_outline)),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(BuildContext context, IconData icon) {
    return GestureDetector(
      onTap: () => showInfoSnackBar(context, 'Yakında'),
      child: Container(
        height: 48,
        decoration: cardDecoration(radius: 14),
        child: Icon(icon, color: kOnSurfaceVariant, size: 20),
      ),
    );
  }

  // ── Hesap Yönetimi (hardcoded — gerçek veri indirme/hesap silme YOK) ────────
  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: cardDecoration(),
          child: tappableIconRow(
            context,
            icon: Icons.download_outlined,
            iconBgColor: kSurfaceContainerHigh,
            title: 'Verilerimi İndir',
            subtitle: 'GDPR kapsamında tüm verilerini al',
            onTap: () => showInfoSnackBar(context, 'Yakında'),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => showInfoSnackBar(context, 'Yakında'),
          child: Container(
            decoration: cardDecoration(
              color: kErrorContainer,
              borderColor: kError.withValues(alpha: 0.3),
            ),
            child: IconRow(
              icon: Icons.delete_outline,
              iconBgColor: kError.withValues(alpha: 0.12),
              title: 'Hesabı Sil',
              subtitle: 'Tüm veriler kalıcı olarak silinir',
              showChevron: false,
              titleColor: kError,
              subtitleColor: kError,
            ),
          ),
        ),
      ],
    );
  }
}
