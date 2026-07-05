import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/pressable.dart';
import '../../../../shared/widgets/app_card.dart';

/// Panel de accion SOS: boton central elegante con halo y CTA inferior.
class EmergencySosAction extends StatefulWidget {
  const EmergencySosAction({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.statusHint,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String statusHint;
  final bool enabled;

  @override
  State<EmergencySosAction> createState() => _EmergencySosActionState();
}

class _EmergencySosActionState extends State<EmergencySosAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(EmergencySosAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final bool animate = widget.enabled &&
        !widget.isLoading &&
        widget.onPressed != null;
    if (animate) {
      if (!_pulseController.isAnimating) _pulseController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final bool canTap =
        widget.enabled && !widget.isLoading && widget.onPressed != null;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: <Color>[
                  colors.error.withValues(alpha: 0.10),
                  colors.surfaceContainerLowest,
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  AppStrings.emergencyActionTitle,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppStrings.emergencyActionSubtitle,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 152,
                  height: 152,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      if (canTap)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (BuildContext context, Widget? child) {
                            final double t = Curves.easeOut
                                .transform(_pulseController.value);
                            return _PulseRing(
                              size: 108 + (t * 28),
                              opacity: 0.28 * (1 - t),
                            );
                          },
                        ),
                      if (canTap)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (BuildContext context, Widget? child) {
                            final double t = Curves.easeOut.transform(
                              (_pulseController.value + 0.35) % 1.0,
                            );
                            return _PulseRing(
                              size: 108 + (t * 18),
                              opacity: 0.16 * (1 - t),
                            );
                          },
                        ),
                      Pressable(
                        enabled: canTap,
                        onTap: canTap ? widget.onPressed : null,
                        scale: 0.96,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: canTap
                                  ? <Color>[
                                      colors.error,
                                      Color.lerp(
                                        colors.error,
                                        const Color(0xFFB3261E),
                                        0.4,
                                      )!,
                                    ]
                                  : <Color>[
                                      colors.surfaceContainerHighest,
                                      colors.surfaceContainerHigh,
                                    ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: canTap ? 0.35 : 0.12,
                              ),
                              width: 2,
                            ),
                            boxShadow: canTap
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color:
                                          colors.error.withValues(alpha: 0.35),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ]
                                : null,
                          ),
                          child: SizedBox(
                            width: 108,
                            height: 108,
                            child: Center(
                              child: widget.isLoading
                                  ? SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colors.onError,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.sos_rounded,
                                          size: 34,
                                          color: canTap
                                              ? colors.onError
                                              : colors.onSurfaceVariant,
                                        ),
                                        Text(
                                          'SOS',
                                          style: context.text.titleLarge
                                              ?.copyWith(
                                            color: canTap
                                                ? colors.onError
                                                : colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.touchTargetMin,
                  child: FilledButton.icon(
                    onPressed: canTap ? widget.onPressed : null,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          canTap ? colors.error : colors.surfaceContainerHighest,
                      foregroundColor: canTap
                          ? colors.onError
                          : colors.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    icon: Icon(
                      canTap
                          ? Icons.emergency_rounded
                          : Icons.lock_outline_rounded,
                      size: 20,
                    ),
                    label: Text(AppStrings.emergencyTriggerLabel),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.statusHint,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.error.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
