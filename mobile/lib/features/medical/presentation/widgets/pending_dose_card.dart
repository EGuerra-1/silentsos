import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../models/medication_models.dart';
import '../../utils/medical_formatters.dart';

/// Tarjeta de dosis pendiente con acciones de consumo.
class PendingDoseCard extends StatelessWidget {
  const PendingDoseCard({
    super.key,
    required this.item,
    required this.isLoading,
    required this.onMarkTaken,
    required this.onMarkSkipped,
    required this.onMarkMissed,
  });

  final PendingMedicationModel item;
  final bool isLoading;
  final VoidCallback onMarkTaken;
  final VoidCallback onMarkSkipped;
  final VoidCallback onMarkMissed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final String time = MedicalFormatters.displayTime(item.scheduledTime);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  time,
                  style: context.text.labelLarge?.copyWith(
                    color: colors.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.medicationName, style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.doseLabel,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (item.notes?.isNotEmpty == true) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.notes!,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: AppStrings.markTaken,
            trailingIcon: Icons.check_rounded,
            isLoading: isLoading,
            onPressed: onMarkTaken,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: isLoading ? null : onMarkSkipped,
                child: const Text(AppStrings.markSkipped),
              ),
              Text(
                '·',
                style: context.text.bodySmall?.copyWith(color: colors.outline),
              ),
              TextButton(
                onPressed: isLoading ? null : onMarkMissed,
                child: const Text(AppStrings.markMissed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
