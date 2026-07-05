import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_model.dart';

class _PipelineStep {
  const _PipelineStep({
    required this.status,
    required this.label,
    required this.icon,
  });

  final EmergencyStatus status;
  final String label;
  final IconData icon;
}

enum _StepVisualState { completed, active, pending, failed }

/// Panel de seguimiento con anillo de progreso y timeline vertical.
class EmergencyTrackingPanel extends StatelessWidget {
  const EmergencyTrackingPanel({
    super.key,
    required this.state,
    required this.onReset,
  });

  final EmergencyFlowState state;
  final VoidCallback onReset;

  static const List<_PipelineStep> _steps = <_PipelineStep>[
    _PipelineStep(
      status: EmergencyStatus.pending,
      label: AppStrings.emergencyStatusPending,
      icon: Icons.hourglass_top_rounded,
    ),
    _PipelineStep(
      status: EmergencyStatus.analyzing,
      label: AppStrings.emergencyStatusAnalyzing,
      icon: Icons.psychology_alt_outlined,
    ),
    _PipelineStep(
      status: EmergencyStatus.triageGenerated,
      label: AppStrings.emergencyStatusTriage,
      icon: Icons.description_outlined,
    ),
    _PipelineStep(
      status: EmergencyStatus.audioGenerated,
      label: AppStrings.emergencyStatusAudio,
      icon: Icons.graphic_eq_rounded,
    ),
    _PipelineStep(
      status: EmergencyStatus.callStarted,
      label: AppStrings.emergencyStatusCall,
      icon: Icons.call_rounded,
    ),
    _PipelineStep(
      status: EmergencyStatus.smsSent,
      label: AppStrings.emergencyStatusSms,
      icon: Icons.sms_outlined,
    ),
    _PipelineStep(
      status: EmergencyStatus.completed,
      label: AppStrings.emergencyStatusCompleted,
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final EmergencyModel? emergency = state.emergency;
    if (emergency == null) return const SizedBox.shrink();

    final ColorScheme colors = context.colors;
    final bool failed = state.phase == EmergencyFlowPhase.failed ||
        emergency.status == EmergencyStatus.failed;
    final int currentIndex = _currentIndex(emergency.status, failed);
    final double progress = failed
        ? 0
        : (currentIndex + 1) / _steps.length;
    final int percent = (progress * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(
                        value: failed ? null : progress,
                        strokeWidth: 6,
                        backgroundColor: colors.surfaceContainerHighest,
                        color: failed ? colors.error : colors.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          failed ? '—' : '$percent%',
                          style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: failed ? colors.error : colors.primary,
                          ),
                        ),
                        Text(
                          failed
                              ? AppStrings.emergencyStatusFailed
                              : '${currentIndex + 1}/${_steps.length}',
                          style: context.text.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      failed
                          ? AppStrings.emergencyFailedTitle
                          : AppStrings.emergencyTrackingTitle,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      emergency.displayStatus ??
                          _steps[currentIndex.clamp(0, _steps.length - 1)]
                              .label,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    if (emergency.address?.isNotEmpty == true) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              emergency.address!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.emergencyTrackingStepsTitle.toUpperCase(),
            style: context.text.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List<Widget>.generate(_steps.length, (int index) {
            final _PipelineStep step = _steps[index];
            final _StepVisualState visual = _visualState(
              index: index,
              currentIndex: currentIndex,
              failed: failed,
            );
            final bool isLast = index == _steps.length - 1;

            return _TimelineRow(
              label: step.label,
              icon: step.icon,
              state: visual,
              isLast: isLast,
            );
          }),
          if (state.phase == EmergencyFlowPhase.completed ||
              state.phase == EmergencyFlowPhase.failed) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onReset,
                child: const Text(AppStrings.emergencyReset),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _currentIndex(EmergencyStatus status, bool failed) {
    if (failed) return 0;
    final int index = _steps.indexWhere((step) => step.status == status);
    return index < 0 ? 0 : index;
  }

  _StepVisualState _visualState({
    required int index,
    required int currentIndex,
    required bool failed,
  }) {
    if (failed && index == currentIndex) return _StepVisualState.failed;
    if (index < currentIndex) return _StepVisualState.completed;
    if (index == currentIndex) {
      return failed ? _StepVisualState.failed : _StepVisualState.active;
    }
    return _StepVisualState.pending;
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.icon,
    required this.state,
    required this.isLast,
  });

  final String label;
  final IconData icon;
  final _StepVisualState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color accent = switch (state) {
      _StepVisualState.completed => colors.primary,
      _StepVisualState.active => colors.primary,
      _StepVisualState.failed => colors.error,
      _StepVisualState.pending => colors.onSurfaceVariant,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Column(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: switch (state) {
                      _StepVisualState.completed =>
                        colors.primary.withValues(alpha: 0.12),
                      _StepVisualState.active =>
                        colors.primary.withValues(alpha: 0.16),
                      _StepVisualState.failed =>
                        colors.error.withValues(alpha: 0.12),
                      _StepVisualState.pending =>
                        colors.surfaceContainerHighest,
                    },
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(
                        alpha: state == _StepVisualState.pending ? 0.25 : 0.45,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      state == _StepVisualState.completed
                          ? Icons.check_rounded
                          : icon,
                      size: 16,
                      color: accent,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: state == _StepVisualState.completed
                          ? colors.primary.withValues(alpha: 0.35)
                          : colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: context.text.bodyMedium?.copyWith(
                      color: state == _StepVisualState.pending
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      fontWeight: state == _StepVisualState.active ||
                              state == _StepVisualState.failed
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  if (state == _StepVisualState.active) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.emergencyTrackingStepActive,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
