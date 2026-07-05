import 'package:flutter/material.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Definicion de un destino del menu inferior.
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Menu inferior flotante: icono + label en columna para evitar overflow
/// horizontal con textos largos como "Emergencias" o "Medicamento".
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<AppBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.xs,
          AppSpacing.marginMobile,
          AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.6)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: _NavButton(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onChanged(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color foreground =
        selected ? colors.onPrimary : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: AppDuration.normal,
          curve: AppDuration.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedSwitcher(
                duration: AppDuration.fast,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey<bool>(selected),
                  color: foreground,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(
                  color: foreground,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
