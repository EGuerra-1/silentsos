import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../utils/medical_formatters.dart';

/// Borrador editable de un horario de medicamento en formularios.
class ScheduleDraft {
  ScheduleDraft({
    required this.time,
    this.notes = '',
  });

  TimeOfDay time;
  String notes;
}

/// Editor dinamico de horarios (minimo 1) para crear/actualizar medicamentos.
class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({
    super.key,
    required this.schedules,
    required this.onChanged,
  });

  final List<ScheduleDraft> schedules;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.schedulesLabel, style: context.text.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        ...List<Widget>.generate(schedules.length, (int index) {
          final ScheduleDraft draft = schedules[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == schedules.length - 1
                  ? AppSpacing.sm
                  : AppSpacing.md,
            ),
            child: _ScheduleRow(
              draft: draft,
              canDelete: schedules.length > 1,
              onPickTime: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: draft.time,
                );
                if (picked != null) {
                  draft.time = picked;
                  onChanged();
                }
              },
              onDelete: () {
                schedules.removeAt(index);
                onChanged();
              },
            ),
          );
        }),
        AppButton(
          label: AppStrings.addSchedule,
          variant: AppButtonVariant.secondary,
          trailingIcon: Icons.add_rounded,
          onPressed: () {
            schedules.add(ScheduleDraft(time: const TimeOfDay(hour: 8, minute: 0)));
            onChanged();
          },
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatefulWidget {
  const _ScheduleRow({
    required this.draft,
    required this.canDelete,
    required this.onPickTime,
    required this.onDelete,
  });

  final ScheduleDraft draft;
  final bool canDelete;
  final VoidCallback onPickTime;
  final VoidCallback onDelete;

  @override
  State<_ScheduleRow> createState() => _ScheduleRowState();
}

class _ScheduleRowState extends State<_ScheduleRow> {
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.draft.notes);
    _notesCtrl.addListener(() {
      widget.draft.notes = _notesCtrl.text;
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: LabeledField(
                  label: 'Hora',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.onPickTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.access_time_rounded),
                      ),
                      child: Text(
                        MedicalFormatters.formatTimeOfDay(widget.draft.time),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.canDelete) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  tooltip: 'Eliminar horario',
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: AppStrings.scheduleNotesHint,
            controller: _notesCtrl,
          ),
        ],
      ),
    );
  }
}
