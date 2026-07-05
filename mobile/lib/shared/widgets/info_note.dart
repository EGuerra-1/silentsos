import 'package:flutter/material.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

enum InfoNoteTone { neutral, success, error }

/// Nota informativa con icono, como la nota de cifrado del Registro paso 2
/// o el banner de error del Login en Stitch.
class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.message,
    required this.icon,
    this.tone = InfoNoteTone.neutral,
  });

  final String message;
  final IconData icon;
  final InfoNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final (Color background, Color iconColor, Color textColor) =
        switch (tone) {
      InfoNoteTone.neutral => (
          colors.surfaceContainer,
          context.semantic.success,
          colors.onSurfaceVariant,
        ),
      InfoNoteTone.success => (
          context.semantic.successContainer,
          context.semantic.success,
          colors.onSurface,
        ),
      InfoNoteTone.error => (
          colors.errorContainer,
          colors.error,
          colors.onErrorContainer,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
