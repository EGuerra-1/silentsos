import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'medical_segment_bar.dart';

/// Layout reutilizable: segment bar + subtitulo + contenido scrolleable.
class MedicalTabShell extends StatelessWidget {
  const MedicalTabShell({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.options,
    required this.subtitles,
    required this.children,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<MedicalSegmentOption> options;
  final List<String> subtitles;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MedicalSegmentBar(
          selectedIndex: selectedIndex,
          onChanged: onChanged,
          options: options,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitles[selectedIndex],
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: children,
          ),
        ),
      ],
    );
  }
}
