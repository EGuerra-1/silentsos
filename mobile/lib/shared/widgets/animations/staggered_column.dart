import 'package:flutter/material.dart';
import '../../../core/constants/app_duration.dart';
import 'fade_slide_in.dart';

/// Columna cuyos hijos entran de forma escalonada (uno tras otro).
/// Ideal para formularios y listas de la app (registro, login, etc.).
class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.min,
    this.initialDelay = Duration.zero,
    this.interval = AppDuration.stagger,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Duration initialDelay;
  final Duration interval;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: <Widget>[
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: initialDelay + (interval * i),
            child: children[i],
          ),
      ],
    );
  }
}
