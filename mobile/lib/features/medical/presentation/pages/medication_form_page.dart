import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../models/medication_models.dart';
import '../../providers/medical_provider.dart';
import '../../utils/medical_formatters.dart';
import '../widgets/schedule_editor.dart';

/// Formulario para crear o versionar un plan de medicamento.
class MedicationFormPage extends ConsumerStatefulWidget {
  const MedicationFormPage({super.key, this.initial});

  final MedicationPlanModel? initial;

  @override
  ConsumerState<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends ConsumerState<MedicationFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _doseCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();
  final TextEditingController _frequencyCtrl = TextEditingController();
  final TextEditingController _observationsCtrl = TextEditingController();
  final List<ScheduleDraft> _schedules = <ScheduleDraft>[];

  String? _apiError;
  bool _isSaving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final MedicationPlanModel? initial = widget.initial;
    if (initial != null) {
      _titleCtrl.text = initial.title ?? '';
      _nameCtrl.text = initial.name;
      _doseCtrl.text = initial.dose;
      _unitCtrl.text = initial.unit;
      _frequencyCtrl.text = initial.frequency;
      _observationsCtrl.text = initial.observations ?? '';

      for (final MedicationScheduleModel schedule in initial.activeSchedules) {
        _schedules.add(
          ScheduleDraft(
            time: MedicalFormatters.parseTime(schedule.timeOfDay),
            notes: schedule.notes ?? '',
          ),
        );
      }
    }

    if (_schedules.isEmpty) {
      _schedules.add(ScheduleDraft(time: const TimeOfDay(hour: 8, minute: 0)));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _unitCtrl.dispose();
    _frequencyCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      appBar: CustomAppBar(
        title:
            _isEditing ? AppStrings.editMedication : AppStrings.addMedication,
      ),
      bottomBar: FadeSlideIn(
        delay: AppDuration.stagger * 5,
        child: AppButton(
          label: _isEditing ? AppStrings.saveChanges : AppStrings.addMedication,
          trailingIcon: Icons.check_rounded,
          isLoading: _isSaving,
          onPressed: _save,
        ),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: StaggeredColumn(
            children: <Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                _isEditing
                    ? 'Al guardar se creara una nueva version del tratamiento.'
                    : 'Define el medicamento y al menos un horario de toma.',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: AppStrings.medicationTitleLabel,
                controller: _titleCtrl,
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.medicationNameLabel,
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.medication_outlined),
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      label: AppStrings.medicationDoseLabel,
                      controller: _doseCtrl,
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      label: AppStrings.medicationUnitLabel,
                      controller: _unitCtrl,
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.medicationFrequencyLabel,
                controller: _frequencyCtrl,
                prefixIcon: const Icon(Icons.repeat_rounded),
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.medicationObservationsLabel,
                controller: _observationsCtrl,
                maxLength: 500,
                prefixIcon: const Icon(Icons.info_outline_rounded),
              ),
              const SizedBox(height: AppSpacing.lg),
              ScheduleEditor(
                schedules: _schedules,
                onChanged: () => setState(() {}),
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
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    return null;
  }

  Future<void> _save() async {
    setState(() {
      _apiError = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) return;
    if (_schedules.isEmpty) {
      setState(() => _apiError = AppStrings.scheduleRequired);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        if (_titleCtrl.text.trim().isNotEmpty) 'title': _titleCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'dose': _doseCtrl.text.trim(),
        'unit': _unitCtrl.text.trim(),
        'frequency': _frequencyCtrl.text.trim(),
        if (_observationsCtrl.text.trim().isNotEmpty)
          'observations': _observationsCtrl.text.trim(),
        'schedules': _schedules
            .map(
              (ScheduleDraft draft) => <String, dynamic>{
                'time_of_day': MedicalFormatters.formatTimeOfDay(draft.time),
                if (draft.notes.trim().isNotEmpty) 'notes': draft.notes.trim(),
              },
            )
            .toList(),
      };

      await ref.read(medicalServiceProvider).saveMedication(
            planId: widget.initial?.id,
            payload: payload,
          );

      await Future.wait(<Future<void>>[
        ref.read(medicationsControllerProvider.notifier).load(),
        ref.read(medicalDayControllerProvider.notifier).load(),
      ]);

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      AppLogger.error('[Medical] save medication fallo', error: error);
      final String message = error is AppException
          ? error.message
          : AppStrings.saveMedicalError;
      setState(() => _apiError = message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
