import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

/// Pill de estado (Activo/Inactivo) con colores semanticos del tema.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isActive ? colors.secondaryContainer : colors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive
                  ? colors.onSecondaryContainer
                  : colors.onErrorContainer,
            ),
      ),
    );
  }
}
