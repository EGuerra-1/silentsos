import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../models/medication_models.dart';
import '../../utils/medical_formatters.dart';

/// Estilos visuales para estados de consumo de medicamentos.
abstract final class ConsumptionStatusStyle {
  static (Color bg, Color fg, IconData icon, String label) resolve(
    BuildContext context,
    String status,
  ) {
    final ColorScheme colors = context.colors;

    return switch (status) {
      'consumed' => (
          colors.primaryContainer,
          colors.onPrimaryContainer,
          Icons.check_rounded,
          'Tomado',
        ),
      'skipped' => (
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
          Icons.remove_rounded,
          'Omitido',
        ),
      'missed' => (
          colors.errorContainer,
          colors.onErrorContainer,
          Icons.close_rounded,
          'Perdido',
        ),
      _ => (
          colors.surfaceContainerHigh,
          colors.primary,
          Icons.history_rounded,
          status,
        ),
    };
  }
}

/// Fila del historial de consumos de medicamentos.
class ConsumptionHistoryTile extends StatelessWidget {
  const ConsumptionHistoryTile({super.key, required this.item});

  final MedicationConsumptionModel item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final String name = item.medicationName ?? 'Medicamento';
    final String time = MedicalFormatters.displayTime(
      item.scheduledTime ?? '--:--',
    );
    final (Color bg, Color fg, IconData icon, String label) =
        ConsumptionStatusStyle.resolve(context, item.status);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, size: 18, color: fg),
      ),
      title: Text(name, style: context.text.bodyMedium),
      subtitle: Text(
        '${item.doseLabel} · $time',
        style: context.text.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(label, style: context.text.labelSmall),
      ),
    );
  }
}

/// Lista agrupada de consumos dentro de una tarjeta.
class ConsumptionHistoryCard extends StatelessWidget {
  const ConsumptionHistoryCard({super.key, required this.items});

  final List<MedicationConsumptionModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(items.length, (int index) {
        final MedicationConsumptionModel item = items[index];
        return Column(
          children: <Widget>[
            ConsumptionHistoryTile(item: item),
            if (index < items.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: context.colors.outlineVariant,
              ),
          ],
        );
      }),
    );
  }
}
