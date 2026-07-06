import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

// Profil ve Ayarlar ekranları arasında paylaşılan kart/satır stilleri.
// (Bu iki ekran aynı dosyanın bölünmesiyle oluştu, ortak görsel dil taşıyorlar.)

BoxDecoration cardDecoration({
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

Widget sectionDivider() => Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: kOutlineVariant.withValues(alpha: 0.6),
    );

Widget sectionTitle(String title) {
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

// Ortak ikon+başlık+alt yazı düzeni (Profil'deki sağlık/ayarlar satırları, Ayarlar'daki tüm satırlar)
class IconRow extends StatelessWidget {
  const IconRow({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.titleColor = kOnSurface,
    this.subtitleColor = kOnSurfaceVariant,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
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
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.sourceSans3(
                        color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (showChevron)
            const Icon(Icons.chevron_right, color: kOutlineVariant, size: 20),
        ],
      ),
    );
  }
}

// Ayarlar ekranındaki tıklanabilir (Yakında) satırlar için sarmalayıcı
Widget tappableIconRow(
  BuildContext context, {
  required IconData icon,
  required Color iconBgColor,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: IconRow(
      icon: icon,
      iconBgColor: iconBgColor,
      title: title,
      subtitle: subtitle,
      showChevron: true,
    ),
  );
}
