import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../controllers/medical_controllers.dart';
import '../../models/medication_models.dart';
import '../../providers/medical_provider.dart';
import '../utils/medical_refresh_actions.dart';
import '../widgets/consumption_history_tile.dart';
import '../widgets/medical_section_header.dart';
import '../widgets/medication_card.dart';

/// Gestion de tratamientos: listado, edicion e historial de consumos.
class MedicationsManageTab extends ConsumerWidget {
  const MedicationsManageTab({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    MedicationPlanModel? plan,
  }) async {
    final bool? saved = await AppRouter.openMedicationForm(
      context,
      plan: plan,
    );
    if (saved == true) await MedicalRefreshActions.reloadMedications(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MedicationPlanModel>> plansState =
        ref.watch(medicationsControllerProvider);
    final AsyncValue<MedicalDayState> dayState =
        ref.watch(medicalDayControllerProvider);

    if (plansState.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (plansState.hasError) {
      return ErrorState(
        message: AppStrings.loadMedicalError,
        onRetry: () => MedicalRefreshActions.reloadMedications(ref),
      );
    }

    final List<MedicationPlanModel> plans =
        plansState.valueOrNull ?? const <MedicationPlanModel>[];
    final List<MedicationConsumptionModel> history =
        dayState.valueOrNull?.recentConsumptions ??
            const <MedicationConsumptionModel>[];

    return RefreshIndicator(
      onRefresh: () => MedicalRefreshActions.reloadMedications(ref),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          MedicalSectionHeader(
            title: AppStrings.myMedications,
            count: plans.length,
          ),
          AppButton(
            label: AppStrings.addMedication,
            trailingIcon: Icons.add_rounded,
            onPressed: () => _openForm(context, ref),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (plans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: EmptyState(
                message: AppStrings.medicationsEmpty,
                icon: Icons.medication_outlined,
              ),
            )
          else
            ...List<Widget>.generate(plans.length, (int index) {
              final MedicationPlanModel plan = plans[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == plans.length - 1
                      ? AppSpacing.lg
                      : AppSpacing.md,
                ),
                child: FadeSlideIn(
                  delay: AppDuration.stagger * index,
                  child: MedicationCard(
                    plan: plan,
                    onEdit: () => _openForm(context, ref, plan: plan),
                  ),
                ),
              );
            }),
          MedicalSectionHeader(
            title: AppStrings.consumptionHistory,
            count: history.length,
          ),
          if (history.isEmpty)
            AppCard(
              child: Text(
                AppStrings.consumptionHistoryEmpty,
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: ConsumptionHistoryCard(items: history),
            ),
        ],
      ),
    );
  }
}
