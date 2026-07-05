import 'package:flutter/material.dart';

enum BrandBadgeStyle { filled, soft }

/// Insignia circular de marca usada en Login (escudo relleno) y
/// Reset Password (escudo sobre fondo lavanda suave).
class BrandBadge extends StatelessWidget {
  const BrandBadge({
    super.key,
    required this.icon,
    this.style = BrandBadgeStyle.filled,
    this.size = 64,
  });

  final IconData icon;
  final BrandBadgeStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool filled = style == BrandBadgeStyle.filled;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? colors.primaryContainer : colors.onPrimaryContainer,
      ),
      child: Icon(
        icon,
        size: size * 0.45,
        color: filled ? colors.onPrimary : colors.primaryContainer,
      ),
    );
  }
}
