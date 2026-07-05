import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_model.dart';

/// Resumen del progreso de emergencia con barra y paso actual.
class EmergencyProgressCard extends StatelessWidget {
  const EmergencyProgressCard({
    super.key,
    required this.state,
    required this.onReset,
  });

  final EmergencyFlowState state;
  final VoidCallback onReset;

  static const List<EmergencyStatus> _pipeline = <EmergencyStatus>[
    EmergencyStatus.pending,
    EmergencyStatus.analyzing,
    EmergencyStatus.triageGenerated,
    EmergencyStatus.audioGenerated,
    EmergencyStatus.callStarted,
    EmergencyStatus.smsSent,
    EmergencyStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final EmergencyModel? emergency = state.emergency;
    if (emergency == null) return const SizedBox.shrink();

    final ColorScheme colors = context.colors;
    final bool failed = state.phase == EmergencyFlowPhase.failed ||
        emergency.status == EmergencyStatus.failed;
    final int currentIndex = failed
        ? 0
        : _pipeline.indexOf(emergency.status).clamp(0, _pipeline.length - 1);
    final double progress = failed
        ? 0
        : (currentIndex + 1) / _pipeline.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            failed
                ? AppStrings.emergencyFailedTitle
                : AppStrings.emergencyTrackingTitle,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            emergency.displayStatus ??
                _labelForStatus(emergency.status, failed: failed),
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (emergency.address?.isNotEmpty == true) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              emergency.address!,
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: failed ? null : progress,
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHighest,
              color: failed ? colors.error : colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            failed
                ? AppStrings.emergencyStatusFailed
                : '${currentIndex + 1} / ${_pipeline.length}',
            style: context.text.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
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

  String _labelForStatus(EmergencyStatus status, {required bool failed}) {
    if (failed) return AppStrings.emergencyStatusFailed;
    return switch (status) {
      EmergencyStatus.pending => AppStrings.emergencyStatusPending,
      EmergencyStatus.analyzing => AppStrings.emergencyStatusAnalyzing,
      EmergencyStatus.triageGenerated => AppStrings.emergencyStatusTriage,
      EmergencyStatus.audioGenerated => AppStrings.emergencyStatusAudio,
      EmergencyStatus.callStarted => AppStrings.emergencyStatusCall,
      EmergencyStatus.smsSent => AppStrings.emergencyStatusSms,
      EmergencyStatus.completed => AppStrings.emergencyStatusCompleted,
      EmergencyStatus.failed => AppStrings.emergencyStatusFailed,
    };
  }
}
