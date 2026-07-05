import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../../emergency/controllers/emergency_controller.dart';
import '../../../emergency/models/emergency_model.dart';
import '../../../emergency/providers/emergency_provider.dart';
import '../../../emergency/presentation/widgets/emergency_progress_card.dart';
import '../../../emergency/presentation/widgets/emergency_type_selector.dart';
import '../../../emergency/presentation/widgets/emergency_sos_action.dart';
import '../../../emergency/presentation/widgets/location_status_chip.dart';

/// Tab Emergencias: tipo de alerta, ubicacion y accion SOS.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyControllerProvider.notifier).prepareLocation();
    });
  }

  Future<void> _confirmAndTrigger() async {
    final EmergencyFlowState flow = ref.read(emergencyControllerProvider);
    if (flow.isBusy) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ColorScheme colors = context.colors;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          icon: Icon(Icons.emergency_rounded, color: colors.error, size: 32),
          title: const Text(AppStrings.emergencyConfirmTitle),
          content: Text(
            flow.selectedType == EmergencyType.medical
                ? AppStrings.emergencyConfirmMedical
                : AppStrings.emergencyConfirmGeneral,
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(AppStrings.settingsCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(AppStrings.emergencyConfirmAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await ref.read(emergencyControllerProvider.notifier).triggerSos();
  }

  @override
  Widget build(BuildContext context) {
    final EmergencyFlowState flow = ref.watch(emergencyControllerProvider);
    final bool showProgress = flow.emergency != null &&
        flow.phase != EmergencyFlowPhase.idle;
    final bool canTrigger = flow.phase != EmergencyFlowPhase.tracking &&
        flow.phase != EmergencyFlowPhase.completed;

    return AppPageShell(
      appBar: const CustomAppBar(
        title: AppStrings.emergencyTabTitle,
        showBack: false,
      ),
      child: SingleChildScrollView(
        child: StaggeredColumn(
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),
            FadeSlideIn(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.emergencyConfigSection.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    EmergencyTypeSelector(
                      selected: flow.selectedType,
                      onChanged: ref
                          .read(emergencyControllerProvider.notifier)
                          .selectType,
                      enabled: !flow.isBusy &&
                          flow.phase != EmergencyFlowPhase.tracking,
                    ),
                    if (flow.locationLabel?.isNotEmpty == true) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      LocationStatusChip(
                        ready: flow.locationReady,
                        label: flow.locationLabel,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: AppDuration.stagger,
              child: EmergencySosAction(
                enabled: canTrigger,
                isLoading: flow.isBusy,
                statusHint: _phaseHint(flow),
                onPressed: _confirmAndTrigger,
              ),
            ),
            if (flow.errorMessage != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              InfoNote(
                message: flow.errorMessage!,
                icon: Icons.error_outline,
                tone: InfoNoteTone.error,
              ),
            ],
            if (showProgress) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: AppDuration.stagger * 2,
                child: EmergencyProgressCard(
                  state: flow,
                  onReset: ref
                      .read(emergencyControllerProvider.notifier)
                      .reset,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  String _phaseHint(EmergencyFlowState flow) {
    return switch (flow.phase) {
      EmergencyFlowPhase.locating => AppStrings.emergencyPhaseLocating,
      EmergencyFlowPhase.sending => AppStrings.emergencyPhaseSending,
      EmergencyFlowPhase.tracking => AppStrings.emergencyPhaseTracking,
      EmergencyFlowPhase.completed => AppStrings.emergencyPhaseCompleted,
      EmergencyFlowPhase.failed => AppStrings.emergencyPhaseFailed,
      EmergencyFlowPhase.idle => AppStrings.emergencyPhaseIdle,
    };
  }
}
