import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../utils/medical_formatters.dart';

/// Tarjeta resumen del dia con conteo de dosis pendientes.
class TodaySummaryCard extends StatelessWidget {
  const TodaySummaryCard({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.primaryContainer,
            colors.secondaryContainer,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.35),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                pendingCount > 0
                    ? Icons.notifications_active_outlined
                    : Icons.verified_outlined,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pendingCount > 0
                        ? '$pendingCount dosis pendientes'
                        : 'Al dia con tus medicamentos',
                    style: context.text.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    MedicalFormatters.displayDate(DateTime.now()),
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
