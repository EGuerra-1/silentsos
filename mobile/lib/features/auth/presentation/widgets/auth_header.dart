import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Encabezado centrado de las pantallas de auth (patron de Stitch:
/// titulo semibold centrado + subtitulo slate centrado).
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor,
  });

  final String title;
  final String subtitle;

  /// En Login el titulo va en color de marca; en el resto, onSurface.
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            color: titleColor ?? context.colors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
