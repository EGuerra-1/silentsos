import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/emergency_relationship_options.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../models/emergency_contact_model.dart';
import '../../providers/profile_provider.dart';

/// Formulario para editar el contacto de emergencia del usuario.
class EditEmergencyContactPage extends ConsumerStatefulWidget {
  const EditEmergencyContactPage({super.key, this.initial});

  final EmergencyContactModel? initial;

  @override
  ConsumerState<EditEmergencyContactPage> createState() =>
      _EditEmergencyContactPageState();
}

class _EditEmergencyContactPageState
    extends ConsumerState<EditEmergencyContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  String? _relationship;
  String? _contactId;
  String? _apiError;
  String? _loadError;
  bool _isSaving = false;
  bool _isLoading = false;
  bool _missingContact = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _applyContact(widget.initial!);
    } else {
      _loadContact();
    }
  }

  Future<void> _loadContact() async {
    setState(() => _isLoading = true);
    try {
      final EmergencyContactModel? contact =
          await ref.read(profileServiceProvider).getEmergencyContact();
      if (!mounted) return;
      if (contact == null) {
        setState(() => _missingContact = true);
      } else {
        setState(() => _applyContact(contact));
      }
    } catch (error) {
      AppLogger.error('[Profile] load contact fallo', error: error);
      if (!mounted) return;
      setState(() => _loadError = AppStrings.loadProfileError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyContact(EmergencyContactModel contact) {
    _contactId = contact.id;
    _nameCtrl.text = contact.fullName;
    _phoneCtrl.text = contact.cellphone;
    _relationship = contact.relationship;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit =
        _loadError == null && !_isLoading && !_missingContact && _contactId != null;

    return AppPageShell(
      appBar: const CustomAppBar(title: AppStrings.editEmergencyContactTitle),
      bottomBar: canEdit
          ? FadeSlideIn(
              delay: AppDuration.stagger * 4,
              child: AppButton(
                label: AppStrings.saveChanges,
                trailingIcon: Icons.check_rounded,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            )
          : null,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                  ),
                )
              : _missingContact
                  ? Center(
                      child: Text(
                        AppStrings.emergencyContactMissing,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom +
                            AppSpacing.lg,
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autovalidateMode,
                        child: StaggeredColumn(
                          children: <Widget>[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              AppStrings.editEmergencyContactSubtitle,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            LabeledField(
                              label: AppStrings.contactNameLabel,
                              child: AppTextField(
                                hint: AppStrings.contactNameHint,
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                                maxLength: 250,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: _required,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            LabeledField(
                              label: AppStrings.contactPhoneLabel,
                              child: AppTextField(
                                hint: AppStrings.contactPhoneHint,
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                maxLength: 20,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                validator: _required,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            LabeledField(
                              label: AppStrings.contactRelationshipLabel,
                              child: DropdownButtonFormField<String>(
                                key: ValueKey<String?>(_relationship),
                                initialValue: _relationship,
                                items: EmergencyRelationshipOptions.dropdownItems(
                                  _relationship,
                                )
                                    .map(
                                      (String option) =>
                                          DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? value) =>
                                    setState(() => _relationship = value),
                                validator: (String? value) => value == null
                                    ? AppStrings.validationRequired
                                    : null,
                                hint: const Text(
                                  AppStrings.contactRelationshipHint,
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.family_restroom_outlined,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const InfoNote(
                              message: AppStrings.contactPrivacyNote,
                              icon: Icons.verified_user_outlined,
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

  Future<void> _save() async {
    final String? contactId = _contactId;
    if (contactId == null || _relationship == null) return;

    setState(() {
      _apiError = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final EmergencyContactModel updated =
          await ref.read(profileServiceProvider).updateEmergencyContact(
            id: contactId,
            fullName: _nameCtrl.text.trim(),
            cellphone: _phoneCtrl.text.trim(),
            relationship: _relationship!,
          );

      if (mounted) Navigator.pop(context, updated);
    } catch (error) {
      AppLogger.error('[Profile] update contact fallo', error: error);
      setState(() => _apiError = _prettyError(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    return null;
  }

  String _prettyError(Object error) {
    final String raw = error.toString();
    const String prefix = 'AppException(';
    if (raw.startsWith(prefix) && raw.endsWith(')')) {
      return raw.substring(prefix.length, raw.length - 1);
    }
    return AppStrings.saveProfileError;
  }
}
