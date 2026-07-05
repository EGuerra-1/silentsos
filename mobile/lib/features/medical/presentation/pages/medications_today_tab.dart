import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../controllers/medical_controllers.dart';
import '../../models/medication_models.dart';
import '../../providers/medical_provider.dart';
import '../widgets/medical_section_header.dart';
import '../widgets/pending_dose_card.dart';
import '../widgets/today_summary_card.dart';

/// Vista principal: dosis pendientes de hoy con accion rapida de consumo.
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
        return RefreshIndicator(
          onRefresh: () => ref.read(medicalDayControllerProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: <Widget>[
              TodaySummaryCard(pendingCount: day.pending.length),
              const SizedBox(height: AppSpacing.lg),
              if (day.pending.isEmpty)
                const EmptyState(
                  message: AppStrings.pendingEmpty,
                  icon: Icons.check_circle_outline,
                )
              else ...<Widget>[
                MedicalSectionHeader(
                  title: AppStrings.pendingToday,
                  count: day.pending.length,
                ),
                ...day.pending.map((PendingMedicationModel item) {
                  final String key =
                      '${item.medicationPlanId}-${item.scheduledTime}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: PendingDoseCard(
                      item: item,
                      isLoading: _processingKey == key,
                      onMarkTaken: () => _mark(item, 'consumed', key),
                      onMarkSkipped: () => _mark(item, 'skipped', key),
                      onMarkMissed: () => _mark(item, 'missed', key),
                    ),
                  );
                }),
              ],
            ],
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
