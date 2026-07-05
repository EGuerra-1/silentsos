import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Fila compacta con estado del GPS para la tarjeta de configuracion SOS.
class LocationStatusChip extends StatelessWidget {
  const LocationStatusChip({
    super.key,
    required this.ready,
    this.label,
  });

  final bool ready;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color iconBg = ready
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final Color iconFg =
        ready ? colors.onPrimaryContainer : colors.onSurfaceVariant;

    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            ready ? Icons.my_location_rounded : Icons.location_searching_rounded,
            size: 20,
            color: iconFg,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                ready
                    ? AppStrings.emergencyLocationReady
                    : AppStrings.emergencyLocationPending,
                style: context.text.labelLarge,
              ),
              if (label != null && label!.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
