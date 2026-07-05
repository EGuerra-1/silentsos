import 'package:flutter/material.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../models/emergency_model.dart';

/// Selector Medica | General al estilo segment bar del design system.
class EmergencyTypeSelector extends StatelessWidget {
  const EmergencyTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final EmergencyType selected;
  final ValueChanged<EmergencyType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: EmergencyType.values.map((EmergencyType type) {
          final bool isSelected = selected == type;
          return Expanded(
            child: _TypeOption(
              label: type == EmergencyType.medical
                  ? AppStrings.emergencyTypeMedical
                  : AppStrings.emergencyTypeGeneral,
              icon: type == EmergencyType.medical
                  ? Icons.medical_services_outlined
                  : Icons.report_gmailerrorred_outlined,
              selected: isSelected,
              enabled: enabled,
              onTap: () => onChanged(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color foreground =
        selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppDuration.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
