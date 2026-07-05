import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../models/user_disease_model.dart';
import '../../utils/medical_formatters.dart';

/// Tarjeta compacta para una enfermedad registrada del usuario.
class DiseaseCard extends StatelessWidget {
  const DiseaseCard({
    super.key,
    required this.disease,
    required this.onEdit,
  });

  final UserDiseaseModel disease;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.coronavirus_outlined,
              color: colors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(disease.displayName, style: context.text.titleMedium),
                if (disease.displayClassification.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    disease.displayClassification,
                    style: context.text.labelSmall?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
                if (disease.diagnosedAt != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Diagnosticada: ${MedicalFormatters.displayDate(disease.diagnosedAt)}',
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (disease.notes?.isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    disease.notes!,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}
