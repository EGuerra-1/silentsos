import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../models/user_disease_model.dart';
import '../../providers/medical_provider.dart';
import '../widgets/disease_card.dart';

/// Tab de enfermedades: listado del usuario con acceso a formulario add/edit.
class DiseasesTab extends ConsumerWidget {
  const DiseasesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<UserDiseaseModel>> state =
        ref.watch(diseasesControllerProvider);

    return state.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (Object _, StackTrace __) => ErrorState(
        message: AppStrings.loadMedicalError,
        onRetry: () => ref.read(diseasesControllerProvider.notifier).load(),
      ),
      data: (List<UserDiseaseModel> diseases) {
        return RefreshIndicator(
          onRefresh: () => ref.read(diseasesControllerProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: <Widget>[
              if (diseases.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: EmptyState(
                    message: AppStrings.diseasesEmpty,
                    icon: Icons.coronavirus_outlined,
                  ),
                )
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xs,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    'TUS ENFERMEDADES',
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                ...List<Widget>.generate(diseases.length, (int index) {
                  final UserDiseaseModel disease = diseases[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == diseases.length - 1
                          ? AppSpacing.lg
                          : AppSpacing.md,
                    ),
                    child: FadeSlideIn(
                      delay: AppDuration.stagger * index,
                      child: DiseaseCard(
                        disease: disease,
                        onEdit: () => _openForm(context, disease: disease),
                      ),
                    ),
                  );
                }),
              ],
              AppButton(
                label: AppStrings.addDisease,
                trailingIcon: Icons.add_rounded,
                onPressed: () => _openForm(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, {UserDiseaseModel? disease}) async {
    await Navigator.pushNamed(
      context,
      disease == null ? AppRouter.addDisease : AppRouter.editDisease,
      arguments: disease,
    );
  }
}
