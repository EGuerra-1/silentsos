import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';

/// Bloque de ajustes con titulo de seccion + tarjeta contenedora.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        AppCard(child: child),
      ],
    );
  }
}
