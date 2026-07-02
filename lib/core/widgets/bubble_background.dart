import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BubbleBackground extends StatelessWidget {
  const BubbleBackground({super.key, this.isDark = false});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final sageAlpha = isDark ? 0.08 : 0.12;
    final peachAlpha = isDark ? 0.08 : 0.10;
    final grayAlpha = isDark ? 0.08 : 0.16;

    Color bubble(Color c, double alpha) => isDark
        ? Colors.white.withValues(alpha: alpha + 0.06)
        : c.withValues(alpha: alpha);

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -size.height * 0.06,
            right: -size.width * 0.12,
            child: _Bubble(size: size.width * 0.38, color: bubble(kOutlineVariant, grayAlpha)),
          ),
          Positioned(
            top: size.height * 0.08,
            right: size.width * 0.02,
            child: _Bubble(size: size.width * 0.18, color: bubble(kSecondary, peachAlpha + 0.04)),
          ),
          Positioned(
            top: size.height * 0.20,
            left: size.width * 0.05,
            child: _Bubble(size: size.width * 0.10, color: bubble(kPrimary, sageAlpha)),
          ),
          Positioned(
            top: size.height * 0.48,
            right: size.width * 0.08,
            child: _Bubble(size: size.width * 0.08, color: bubble(kSecondary, peachAlpha)),
          ),
          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.10,
            child: _Bubble(size: size.width * 0.42, color: bubble(kPrimary, sageAlpha - 0.03)),
          ),
          Positioned(
            bottom: size.height * 0.08,
            right: size.width * 0.04,
            child: _Bubble(size: size.width * 0.16, color: bubble(kOutlineVariant, grayAlpha - 0.05)),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
