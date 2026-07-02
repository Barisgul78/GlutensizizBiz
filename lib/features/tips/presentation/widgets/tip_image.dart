import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// İpucu görseli — asset yüklenemezse gri kutu + ikon gösterir.
/// Boyutlandırma çağıran taraftaki SizedBox/AspectRatio ile yapılır.
class TipImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;
  final double iconSize;

  const TipImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: kSurfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            color: kOnSurfaceVariant, size: iconSize),
      ),
    );
  }
}
