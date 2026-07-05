import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_model.dart';

/// Encabezado dashboard de la pestana Emergencias.
class EmergencyDashboardHeader extends StatelessWidget {
  const EmergencyDashboardHeader({
    super.key,
    required this.flow,
    this.isActive = false,
  });

  final EmergencyFlowState flow;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final bool failed = flow.phase == EmergencyFlowPhase.failed ||
        flow.emergency?.status == EmergencyStatus.failed;
    final bool completed = flow.phase == EmergencyFlowPhase.completed;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? <Color>[
                  (failed ? colors.error : colors.primary)
                      .withValues(alpha: 0.12),
                  colors.surfaceContainerLowest,
                  colors.tertiary.withValues(alpha: 0.06),
                ]
              : <Color>[
                  colors.primary.withValues(alpha: 0.08),
                  colors.surfaceContainerLowest,
                  colors.error.withValues(alpha: 0.04),
                ],
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: -18,
            right: -10,
            child: _Orb(
              size: 72,
              color: colors.primary.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -24,
            left: -12,
            child: _Orb(
              size: 56,
              color: colors.error.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isActive
                                ? AppStrings.emergencyDashboardActiveTitle
                                : AppStrings.emergencyDashboardTitle,
                            style: context.text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _subtitle(isActive, failed, completed),
                            style: context.text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _HeaderIcon(
                      isActive: isActive,
                      failed: failed,
                      completed: completed,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    if (isActive && !failed && !completed)
                      const _LiveStatusChip(),
                    _StatusChip(
                      icon: flow.locationReady
                          ? Icons.my_location_rounded
                          : Icons.location_searching_rounded,
                      label: flow.locationReady
                          ? AppStrings.emergencyLocationReady
                          : AppStrings.emergencyLocationPending,
                      accent: flow.locationReady
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                    if (!isActive)
                      _StatusChip(
                        icon: Icons.verified_user_outlined,
                        label: AppStrings.emergencyHeroBadge,
                        accent: colors.primary,
                      ),
                    if (isActive && flow.isContextual)
                      _StatusChip(
                        icon: Icons.auto_awesome_outlined,
                        label: AppStrings.emergencyDashboardContextBadge,
                        accent: colors.tertiary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(bool active, bool failed, bool completed) {
    if (!active) return AppStrings.emergencyDashboardSubtitle;
    if (failed) return AppStrings.emergencyPhaseFailed;
    if (completed) return AppStrings.emergencyPhaseCompleted;
    return flow.emergency?.displayStatus ??
        AppStrings.emergencyPhaseTracking;
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.isActive,
    required this.failed,
    required this.completed,
  });

  final bool isActive;
  final bool failed;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color accent = failed
        ? colors.error
        : completed
            ? colors.primary
            : isActive
                ? colors.primary
                : colors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          failed
              ? Icons.error_outline_rounded
              : completed
                  ? Icons.check_circle_outline_rounded
                  : isActive
                      ? Icons.emergency_share_rounded
                      : Icons.shield_outlined,
          color: accent,
          size: 26,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStatusChip extends StatefulWidget {
  const _LiveStatusChip();

  @override
  State<_LiveStatusChip> createState() => _LiveStatusChipState();
}

class _LiveStatusChipState extends State<_LiveStatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FadeTransition(
            opacity: Tween<double>(begin: 0.45, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            AppStrings.emergencyDashboardLiveBadge,
            style: context.text.labelSmall?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
