import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../models/medication_models.dart';
import '../../utils/medical_formatters.dart';

/// Tarjeta de dosis pendiente con acciones rapidas de consumo.
class PendingMedicationCard extends StatelessWidget {
  const PendingMedicationCard({
    super.key,
    required this.item,
    required this.isLoading,
    required this.onMarkConsumed,
    required this.onMarkSkipped,
    required this.onMarkMissed,
  });

  final PendingMedicationModel item;
  final bool isLoading;
  final VoidCallback onMarkConsumed;
  final VoidCallback onMarkSkipped;
  final VoidCallback onMarkMissed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: colors.onTertiaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.medicationName, style: context.text.titleSmall),
                    Text(
                      '${item.dose} · ${MedicalFormatters.displayTime(item.scheduledTime)}',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (item.notes?.isNotEmpty == true)
                      Text(
                        item.notes!,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.markConsumed,
            variant: AppButtonVariant.primary,
            isLoading: isLoading,
            onPressed: onMarkConsumed,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: AppStrings.markSkipped,
                  variant: AppButtonVariant.secondary,
                  isLoading: isLoading,
                  onPressed: onMarkSkipped,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppButton(
                  label: AppStrings.markMissed,
                  variant: AppButtonVariant.text,
                  isLoading: isLoading,
                  onPressed: onMarkMissed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
