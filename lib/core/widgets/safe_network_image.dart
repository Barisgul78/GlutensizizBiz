import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Firestore 'resim' alanı URL veya asset adı olabilir (bkz. CLAUDE.md).
// Geçerli http(s) URL değilse network denemeden doğrudan fallback ikon gösterir.
class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.fallbackIcon,
    this.fallbackIconColor = kOnSurfaceVariant,
    this.fallbackIconSize,
    this.fallbackBackgroundColor = kSurfaceContainerHighest,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final double? fallbackIconSize;
  final Color fallbackBackgroundColor;

  bool get _isValidUrl =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) return _fallback();
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: fallbackBackgroundColor,
        child: Icon(fallbackIcon, color: fallbackIconColor, size: fallbackIconSize),
      );
}
