import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/pressable.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../models/emergency_model.dart';
import 'emergency_type_selector.dart';

/// Panel unificado: SOS arriba, contexto abajo, estilo limpio del design system.
class EmergencyDualActionsPanel extends StatelessWidget {
  const EmergencyDualActionsPanel({
    super.key,
    required this.onSosPressed,
    required this.onContextualPressed,
    required this.statusHint,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
    this.typeEnabled = true,
    this.sosLoading = false,
    this.contextualLoading = false,
  });

  final VoidCallback? onSosPressed;
  final VoidCallback? onContextualPressed;
  final String statusHint;
  final EmergencyType selectedType;
  final ValueChanged<EmergencyType> onTypeChanged;
  final bool enabled;
  final bool typeEnabled;
  final bool sosLoading;
  final bool contextualLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final bool sosCanTap =
        enabled && !sosLoading && !contextualLoading && onSosPressed != null;
    final bool contextualCanTap = enabled &&
        !sosLoading &&
        !contextualLoading &&
        onContextualPressed != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SosSection(
                colors: colors,
                canTap: sosCanTap,
                isLoading: sosLoading,
                selectedType: selectedType,
                typeEnabled: typeEnabled,
                onTypeChanged: onTypeChanged,
                onPressed: onSosPressed,
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: colors.outlineVariant.withValues(alpha: 0.45),
              ),
              _ContextSection(
                colors: colors,
                canTap: contextualCanTap,
                isLoading: contextualLoading,
                onPressed: onContextualPressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          statusHint,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _SosSection extends StatelessWidget {
  const _SosSection({
    required this.colors,
    required this.canTap,
    required this.isLoading,
    required this.selectedType,
    required this.typeEnabled,
    required this.onTypeChanged,
    required this.onPressed,
  });

  final ColorScheme colors;
  final bool canTap;
  final bool isLoading;
  final EmergencyType selectedType;
  final bool typeEnabled;
  final ValueChanged<EmergencyType> onTypeChanged;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.error.withValues(alpha: 0.05),
            colors.surfaceContainerLowest,
          ],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.emergencySosModeTitle,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppStrings.emergencySosModeSubtitle,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _SosOrb(
                enabled: canTap,
                loading: isLoading,
                onPressed: onPressed,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          EmergencyTypeSelector(
            selected: selectedType,
            onChanged: onTypeChanged,
            enabled: typeEnabled,
          ),
        ],
      ),
    );
  }
}

class _ContextSection extends StatelessWidget {
  const _ContextSection({
    required this.colors,
    required this.canTap,
    required this.isLoading,
    required this.onPressed,
  });

  final ColorScheme colors;
  final bool canTap;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.12),
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.xl),
      ),
      child: InkWell(
        onTap: canTap ? onPressed : null,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : Icon(
                          Icons.photo_camera_front_rounded,
                          color: canTap
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.emergencyContextModeTitle,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.emergencyContextModeSubtitle,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_rounded,
                color: canTap ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosOrb extends StatelessWidget {
  const _SosOrb({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Pressable(
      enabled: enabled,
      onTap: enabled ? onPressed : null,
      scale: 0.96,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: enabled
                ? <Color>[
                    colors.error,
                    colors.error.withValues(alpha: 0.82),
                  ]
                : <Color>[
                    colors.surfaceContainerHighest,
                    colors.surfaceContainerHigh,
                  ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.4 : 0.12),
            width: 2,
          ),
          boxShadow: enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: colors.error.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: SizedBox(
          width: 68,
          height: 68,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.onError,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.sos_rounded,
                        size: 24,
                        color: enabled
                            ? colors.onError
                            : colors.onSurfaceVariant,
                      ),
                      Text(
                        'SOS',
                        style: context.text.labelMedium?.copyWith(
                          color: enabled
                              ? colors.onError
                              : colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
