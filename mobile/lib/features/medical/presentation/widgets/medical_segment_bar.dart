import 'package:flutter/material.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Opcion del selector segmentado del modulo medico.
class MedicalSegmentOption {
  const MedicalSegmentOption({
    required this.label,
    required this.icon,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final int? badgeCount;
}

/// Selector segmentado con icono y badge opcional (estilo Stitch).
class MedicalSegmentBar extends StatelessWidget {
  const MedicalSegmentBar({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<MedicalSegmentOption> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

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
        children: List<Widget>.generate(options.length, (int index) {
          final MedicalSegmentOption option = options[index];
          return Expanded(
            child: _SegmentItem(
              option: option,
              selected: selectedIndex == index,
              onTap: () => onChanged(index),
            ),
          );
        }),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final MedicalSegmentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color foreground =
        selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: colors.primaryContainer.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(option.icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(color: foreground),
              ),
            ),
            if (option.badgeCount != null && option.badgeCount! > 0) ...<Widget>[
              const SizedBox(width: AppSpacing.xxs),
              _Badge(count: option.badgeCount!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: context.text.labelSmall?.copyWith(
          color: colors.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
