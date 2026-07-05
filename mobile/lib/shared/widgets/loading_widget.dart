import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.label = 'Cargando...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          width: AppSpacing.xxl,
          height: AppSpacing.xxl,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(label),
      ],
    );
  }
}
