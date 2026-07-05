import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/brand_badge.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Pantalla de Medicamentos: por ahora un estado inicial limpio y moderno
/// con la estructura lista para listar tratamientos.
class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      appBar: const CustomAppBar(title: 'Medicamentos', showBack: false),
      child: SingleChildScrollView(
        child: StaggeredColumn(
          children: <Widget>[
            const SizedBox(height: AppSpacing.md),
            const _MedicationsHero(),
            const SizedBox(height: AppSpacing.lg),
            _InfoTile(
              icon: Icons.schedule_rounded,
              title: 'Recordatorios',
              subtitle: 'Programa horarios para no olvidar ninguna dosis.',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoTile(
              icon: Icons.inventory_2_outlined,
              title: 'Inventario',
              subtitle: 'Lleva el control de tus existencias disponibles.',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Agregar medicamento',
              trailingIcon: Icons.add_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _MedicationsHero extends StatelessWidget {
  const _MedicationsHero();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: <Widget>[
          const BrandBadge(
            icon: Icons.medication_outlined,
            style: BrandBadgeStyle.soft,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tus medicamentos, bajo control',
            textAlign: TextAlign.center,
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Aun no tienes medicamentos registrados. Agrega el primero para '
            'recibir recordatorios seguros.',
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: context.text.bodyLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
