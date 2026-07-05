import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../models/disease_catalog_model.dart';
import '../../models/user_disease_model.dart';
import '../../providers/medical_provider.dart';
import '../widgets/disease_catalog_picker.dart';

/// Formulario reutilizable para crear o editar una enfermedad del usuario.
class DiseaseFormPage extends ConsumerStatefulWidget {
  const DiseaseFormPage({super.key, this.initial});

  /// Si se envia, el formulario opera en modo edicion (PUT).
  final UserDiseaseModel? initial;

  @override
  ConsumerState<DiseaseFormPage> createState() => _DiseaseFormPageState();
}

class _DiseaseFormPageState extends ConsumerState<DiseaseFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _notesCtrl = TextEditingController();

  String? _selectedCatalogId;
  DateTime? _diagnosedAt;
  String? _apiError;
  bool _isSaving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final UserDiseaseModel? initial = widget.initial;
    if (initial != null) {
      _selectedCatalogId = initial.diseaseCatalogId;
      _notesCtrl.text = initial.notes ?? '';
      _diagnosedAt = initial.diagnosedAt;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<DiseaseCatalogModel>> catalogState =
        ref.watch(diseaseCatalogControllerProvider);

    return AppPageShell(
      appBar: CustomAppBar(
        title: _isEditing ? AppStrings.editDisease : AppStrings.addDisease,
      ),
      bottomBar: FadeSlideIn(
        delay: AppDuration.stagger * 4,
        child: AppButton(
          label: _isEditing ? AppStrings.saveChanges : AppStrings.addDisease,
          trailingIcon: Icons.check_rounded,
          isLoading: _isSaving,
          onPressed: _save,
        ),
      ),
      child: catalogState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => Center(
          child: Text(
            AppStrings.loadMedicalError,
            textAlign: TextAlign.center,
          ),
        ),
        data: (List<DiseaseCatalogModel> catalog) {
          final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: keyboardInset + AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: StaggeredColumn(
                children: <Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isEditing
                        ? 'Actualiza la informacion de tu enfermedad.'
                        : 'Selecciona una enfermedad del catalogo y agrega '
                            'detalles opcionales.',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DiseaseCatalogPicker(
                    catalog: catalog,
                    selectedId: _selectedCatalogId,
                    onChanged: (DiseaseCatalogModel item) {
                      setState(() => _selectedCatalogId = item.id);
                    },
                    validator: (String? value) {
                      if (_selectedCatalogId == null) {
                        return AppStrings.selectDiseaseRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: AppStrings.diseaseNotesLabel,
                    hint: AppStrings.diseaseNotesHint,
                    controller: _notesCtrl,
                    maxLength: 500,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MedicalDateField(
                    label: AppStrings.diseaseDiagnosedLabel,
                    value: _diagnosedAt,
                    onChanged: (DateTime? date) {
                      setState(() => _diagnosedAt = date);
                    },
                  ),
                  if (_apiError != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    InfoNote(
                      message: _apiError!,
                      icon: Icons.error_outline,
                      tone: InfoNoteTone.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _apiError = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate() || _selectedCatalogId == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(medicalServiceProvider).saveUserDisease(
            id: widget.initial?.id,
            diseaseCatalogId: _selectedCatalogId!,
            notes: _notesCtrl.text.trim(),
            diagnosedAt: _diagnosedAt,
          );

      await ref.read(diseasesControllerProvider.notifier).load();

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      AppLogger.error('[Medical] save disease fallo', error: error);
      setState(() => _apiError = AppStrings.saveMedicalError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
