import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product.dart';

/// Ürün güvenlik durumunu gösteren küçük rozet (GÜVENLİ / RİSKLİ / ?).
class ProductStatusBadge extends StatelessWidget {
  final ProductStatus status;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final double letterSpacing;

  const ProductStatusBadge({
    super.key,
    required this.status,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    this.borderRadius = 4,
    this.fontSize = 8,
    this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String text;
    switch (status) {
      case ProductStatus.safe:
        bg = kPrimary;
        fg = kOnPrimary;
        text = 'GÜVENLİ';
      case ProductStatus.risky:
        bg = kError;
        fg = Colors.white;
        text = 'RİSKLİ';
      case ProductStatus.unknown:
        bg = kSurfaceContainerHighest;
        fg = kOnSurfaceVariant;
        text = '?';
    }
    return Container(
      padding: padding,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(borderRadius)),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
