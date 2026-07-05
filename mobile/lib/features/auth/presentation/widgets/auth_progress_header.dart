import 'package:flutter/material.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Barra de progreso redondeada con caption centrado ("Paso X de Y"),
/// tal como aparece en Reset Password de Stitch.
class AuthProgressHeader extends StatelessWidget {
  const AuthProgressHeader({
    super.key,
    required this.progress,
    required this.caption,
  });

  final double progress;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: AppDuration.normal,
            curve: AppDuration.easeOut,
            builder: (BuildContext context, double value, Widget? _) {
              return LinearProgressIndicator(value: value, minHeight: 6);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          caption,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }
}
