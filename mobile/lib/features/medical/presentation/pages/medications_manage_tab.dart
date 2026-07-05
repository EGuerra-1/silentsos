import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../controllers/medical_controllers.dart';
import '../../models/medication_models.dart';
import '../../providers/medical_provider.dart';
import '../../utils/medical_formatters.dart';
import '../widgets/medication_card.dart';

/// Historial y gestion de tratamientos: listado, edicion y consumos.
class MedicationsManageTab extends ConsumerWidget {
  const MedicationsManageTab({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait(<Future<void>>[
      ref.read(medicationsControllerProvider.notifier).load(),
      ref.read(medicalDayControllerProvider.notifier).load(),
    ]);
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
        onRetry: () => _refresh(ref),
      );
    }

    final List<MedicationPlanModel> plans =
        plansState.valueOrNull ?? const <MedicationPlanModel>[];
    final List<MedicationConsumptionModel> history =
        dayState.valueOrNull?.recentConsumptions ??
            const <MedicationConsumptionModel>[];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          AppButton(
            label: AppStrings.addMedication,
            trailingIcon: Icons.add_rounded,
            onPressed: () async {
              final bool? saved =
                  await Navigator.pushNamed(context, AppRouter.addMedication);
              if (saved == true) await _refresh(ref);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: AppStrings.myMedications),
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
                    onEdit: () async {
                      final bool? saved = await Navigator.pushNamed(
                        context,
                        AppRouter.editMedication,
                        arguments: plan,
                      );
                      if (saved == true) await _refresh(ref);
                    },
                  ),
                ),
              );
            }),
          _SectionTitle(title: AppStrings.consumptionHistory),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                AppStrings.consumptionHistoryEmpty,
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            )
          else
            ...history.map(
              (MedicationConsumptionModel item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ConsumptionHistoryTile(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _ConsumptionHistoryTile extends StatelessWidget {
  const _ConsumptionHistoryTile({required this.item});

  final MedicationConsumptionModel item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final String name = item.medicationName ?? 'Medicamento';
    final String time = MedicalFormatters.displayTime(
      item.scheduledTime ?? '--:--',
    );
    final String statusLabel = switch (item.status) {
      'consumed' => 'Tomado',
      'skipped' => 'Omitido',
      'missed' => 'Perdido',
      _ => item.status,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.surfaceContainerHigh,
        child: Icon(_statusIcon(item.status), size: 18, color: colors.primary),
      ),
      title: Text(name, style: context.text.bodyMedium),
      subtitle: Text(
        '${item.doseLabel} · $time · $statusLabel',
        style: context.text.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'consumed' => Icons.check_circle_outline,
      'skipped' => Icons.remove_circle_outline,
      'missed' => Icons.error_outline,
      _ => Icons.history_rounded,
    };
  }
}
