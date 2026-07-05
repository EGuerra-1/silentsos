import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../models/medication_models.dart';
import '../../utils/medical_formatters.dart';

/// Tarjeta de un plan de medicamento con horarios activos.
class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.plan,
    required this.onEdit,
  });

  final MedicationPlanModel plan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final List<MedicationScheduleModel> schedules = plan.activeSchedules;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.medication_liquid_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(plan.name, style: context.text.titleMedium),
                    Text(
                      '${plan.doseLabel} · ${plan.frequency}',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (plan.title?.isNotEmpty == true)
                      Text(
                        plan.title!,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          if (schedules.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: schedules
                  .map(
                    (MedicationScheduleModel schedule) => _ScheduleChip(
                      time: MedicalFormatters.displayTime(schedule.timeOfDay),
                      notes: schedule.notes,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (plan.observations?.isNotEmpty == true) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              plan.observations!,
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({required this.time, this.notes});

  final String time;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final String label =
        notes?.isNotEmpty == true ? '$time · $notes' : time;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(label, style: context.text.labelSmall),
    );
  }
}
