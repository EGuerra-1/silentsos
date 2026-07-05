import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../controllers/theme_mode_controller.dart';

/// Control segmentado para elegir el modo de tema (Sistema/Claro/Oscuro).
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  static const List<(ThemeMode, IconData, String)> _options =
      <(ThemeMode, IconData, String)>[
    (ThemeMode.system, Icons.brightness_auto_rounded, 'Sistema'),
    (ThemeMode.light, Icons.light_mode_rounded, 'Claro'),
    (ThemeMode.dark, Icons.dark_mode_rounded, 'Oscuro'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode current = ref.watch(themeModeControllerProvider);
    final ColorScheme colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          for (final (ThemeMode mode, IconData icon, String label) in _options)
            Expanded(
              child: _SegmentButton(
                icon: icon,
                label: label,
                selected: current == mode,
                onTap: () => ref
                    .read(themeModeControllerProvider.notifier)
                    .setMode(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color foreground =
        selected ? colors.onPrimary : colors.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppDuration.easeOut,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 20, color: foreground),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: context.text.labelSmall?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
