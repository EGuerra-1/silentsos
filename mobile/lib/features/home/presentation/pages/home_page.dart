import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../../emergency/controllers/emergency_controller.dart';
import '../../../emergency/models/emergency_model.dart';
import '../../../emergency/providers/emergency_provider.dart';
import '../../../emergency/presentation/widgets/contextual_emergency_sheet.dart';
import '../../../emergency/presentation/widgets/emergency_dashboard_header.dart';
import '../../../emergency/presentation/widgets/emergency_dual_actions_panel.dart';
import '../../../emergency/presentation/widgets/emergency_tracking_panel.dart';
import '../../../emergency/services/contextual_image_picker.dart';

/// Tab Emergencias con dashboard header y seguimiento visual del protocolo.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isCapturingPhotos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyControllerProvider.notifier).prepareLocation();
    });
  }

  Future<void> _confirmAndTriggerSos() async {
    final EmergencyFlowState flow = ref.read(emergencyControllerProvider);
    if (flow.isBusy || _isCapturingPhotos) return;

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

  Future<void> _startContextualFlow() async {
    final EmergencyFlowState flow = ref.read(emergencyControllerProvider);
    if (flow.isBusy || _isCapturingPhotos) return;

    setState(() => _isCapturingPhotos = true);

    try {
      final ContextualImageCaptureResult? capture =
          await ContextualImagePicker.captureBoth();
      if (!mounted) return;
      if (capture == null) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: false,
        backgroundColor: context.colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        builder: (BuildContext sheetContext) {
          return ContextualEmergencySheet(
            capture: capture,
            onRetake: _startContextualFlow,
          );
        },
      );
    } catch (error) {
      AppLogger.error('[Emergency] captura contextual fallo', error: error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.emergencyContextCameraError)),
      );
    } finally {
      if (mounted) setState(() => _isCapturingPhotos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EmergencyFlowState flow = ref.watch(emergencyControllerProvider);
    final bool showProgress = flow.emergency != null &&
        flow.phase != EmergencyFlowPhase.idle;
    final bool canTrigger = flow.phase != EmergencyFlowPhase.tracking &&
        flow.phase != EmergencyFlowPhase.completed;
    final bool sosBusy = _isSosBusy(flow);
    final bool contextualBusy = _isContextualBusy(flow);

    return AppPageShell(
      appBar: const CustomAppBar(
        title: AppStrings.emergencyTabTitle,
        showBack: false,
      ),
      child: showProgress
          ? _buildTrackingView(flow)
          : _buildIdleView(
              flow: flow,
              canTrigger: canTrigger,
              sosBusy: sosBusy,
              contextualBusy: contextualBusy,
            ),
    );
  }

  Widget _buildIdleView({
    required EmergencyFlowState flow,
    required bool canTrigger,
    required bool sosBusy,
    required bool contextualBusy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FadeSlideIn(
          child: EmergencyDashboardHeader(flow: flow),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: FadeSlideIn(
            delay: AppDuration.stagger,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                EmergencyDualActionsPanel(
                  enabled: canTrigger,
                  typeEnabled: !flow.isBusy,
                  sosLoading: sosBusy,
                  contextualLoading: contextualBusy,
                  statusHint: _phaseHint(flow),
                  selectedType: flow.selectedType,
                  onTypeChanged: ref
                      .read(emergencyControllerProvider.notifier)
                      .selectType,
                  onSosPressed: canTrigger ? _confirmAndTriggerSos : null,
                  onContextualPressed:
                      canTrigger ? _startContextualFlow : null,
                ),
              ],
            ),
          ),
        ),
        if (flow.errorMessage != null) ...<Widget>[
          InfoNote(
            message: flow.errorMessage!,
            icon: Icons.error_outline,
            tone: InfoNoteTone.error,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildTrackingView(EmergencyFlowState flow) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FadeSlideIn(
            child: EmergencyDashboardHeader(flow: flow, isActive: true),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: AppDuration.stagger,
            child: EmergencyTrackingPanel(
              state: flow,
              onReset: ref.read(emergencyControllerProvider.notifier).reset,
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
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: AppDuration.stagger * 2,
            child: Text(
              _phaseHint(flow),
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  bool _isSosBusy(EmergencyFlowState flow) {
    return (flow.phase == EmergencyFlowPhase.locating && !flow.isContextual) ||
        (flow.phase == EmergencyFlowPhase.sending && !flow.isContextual);
  }

  bool _isContextualBusy(EmergencyFlowState flow) {
    return _isCapturingPhotos ||
        (flow.phase == EmergencyFlowPhase.locating && flow.isContextual) ||
        (flow.phase == EmergencyFlowPhase.sending && flow.isContextual);
  }

  String _phaseHint(EmergencyFlowState flow) {
    if (_isCapturingPhotos) {
      return AppStrings.emergencyContextCapturing;
    }
    return switch (flow.phase) {
      EmergencyFlowPhase.locating => AppStrings.emergencyPhaseLocating,
      EmergencyFlowPhase.sending => flow.isContextual
          ? AppStrings.emergencyPhaseSendingContextual
          : AppStrings.emergencyPhaseSending,
      EmergencyFlowPhase.tracking => AppStrings.emergencyPhaseTracking,
      EmergencyFlowPhase.completed => AppStrings.emergencyPhaseCompleted,
      EmergencyFlowPhase.failed => AppStrings.emergencyPhaseFailed,
      EmergencyFlowPhase.idle => AppStrings.emergencyPhaseIdleDual,
    };
  }
}
