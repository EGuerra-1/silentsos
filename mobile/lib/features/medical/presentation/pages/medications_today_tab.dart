import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../controllers/medical_controllers.dart';
import '../../models/medication_models.dart';
import '../../providers/medical_provider.dart';
import '../../utils/medical_formatters.dart';

/// Pantalla principal de medicamentos: dosis pendientes de hoy.
class MedicationsTodayTab extends ConsumerStatefulWidget {
  const MedicationsTodayTab({super.key});

  @override
  ConsumerState<MedicationsTodayTab> createState() =>
      _MedicationsTodayTabState();
}

class _MedicationsTodayTabState extends ConsumerState<MedicationsTodayTab> {
  String? _processingKey;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<MedicalDayState> dayState =
        ref.watch(medicalDayControllerProvider);

    return dayState.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (Object _, StackTrace __) => ErrorState(
        message: AppStrings.loadMedicalError,
        onRetry: () => ref.read(medicalDayControllerProvider.notifier).load(),
      ),
      data: (MedicalDayState day) {
        if (day.pending.isEmpty) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(medicalDayControllerProvider.notifier).load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const <Widget>[
                SizedBox(height: AppSpacing.xxl),
                EmptyState(
                  message: AppStrings.pendingEmpty,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(medicalDayControllerProvider.notifier).load(),
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            itemCount: day.pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final PendingMedicationModel item = day.pending[index];
              final String key =
                  '${item.medicationPlanId}-${item.scheduledTime}';

              return _PendingDoseCard(
                item: item,
                isLoading: _processingKey == key,
                onMarkTaken: () => _mark(item, 'consumed', key),
                onMarkSkipped: () => _mark(item, 'skipped', key),
                onMarkMissed: () => _mark(item, 'missed', key),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _mark(
    PendingMedicationModel item,
    String status,
    String key,
  ) async {
    setState(() => _processingKey = key);
    try {
      await ref.read(medicalDayControllerProvider.notifier).markConsumption(
            item: item,
            status: status,
          );
      await ref.read(medicationsControllerProvider.notifier).load();
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }
}

class _PendingDoseCard extends StatelessWidget {
  const _PendingDoseCard({
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
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: colors.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.medicationName, style: context.text.titleMedium),
                    Text(
                      '${item.doseLabel} · ${MedicalFormatters.displayTime(item.scheduledTime)}',
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
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: AppStrings.markTaken,
            trailingIcon: Icons.check_rounded,
            isLoading: isLoading,
            onPressed: onMarkTaken,
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
