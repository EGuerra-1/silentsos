import 'package:flutter/material.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../models/register_draft.dart';
import '../widgets/auth_header.dart';

const List<String> _relationshipOptions = <String>[
  'Madre',
  'Padre',
  'Hermano/a',
  'Pareja',
  'Amigo/a',
  'Otro',
];

/// Registro paso 2 de Stitch: badge "PASO 2 DE 2" con progreso completo,
/// icono de corazon, campos etiquetados con iconos y CTA fijo.
class RegisterStepTwoPage extends StatefulWidget {
  const RegisterStepTwoPage({super.key});

  @override
  State<RegisterStepTwoPage> createState() => _RegisterStepTwoPageState();
}

class _RegisterStepTwoPageState extends State<RegisterStepTwoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactPhoneCtrl = TextEditingController();
  String? _relationship;
  bool _loading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Draft del paso 1; disponible para el envio final al backend.
    final RegisterDraft? draft =
        ModalRoute.of(context)?.settings.arguments as RegisterDraft?;

    return AppPageShell(
      appBar: const CustomAppBar(
        title: AppStrings.registerStepTwoBadge,
        progress: 1,
      ),
      bottomBar: FadeSlideIn(
        delay: AppDuration.stagger * 5,
        child: AppButton(
          label: AppStrings.registerFinish,
          trailingIcon: Icons.check_circle_outline,
          isLoading: _loading,
          onPressed: () => _finish(draft),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: StaggeredColumn(
            children: <Widget>[
              const SizedBox(height: AppSpacing.xl),
              Icon(
                Icons.favorite_border_rounded,
                size: 32,
                color: context.colors.primaryContainer,
              ),
              const SizedBox(height: AppSpacing.md),
              const AuthHeader(
                title: AppStrings.registerStepTwoTitle,
                subtitle: AppStrings.registerStepTwoSubtitle,
              ),
              const SizedBox(height: AppSpacing.xl),
              LabeledField(
                label: AppStrings.contactNameLabel,
                child: AppTextField(
                  hint: AppStrings.contactNameHint,
                  controller: _contactNameCtrl,
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
                  controller: _contactPhoneCtrl,
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
                  initialValue: _relationship,
                  items: _relationshipOptions
                      .map(
                        (String option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) =>
                      setState(() => _relationship = value),
                  validator: (String? value) =>
                      value == null ? AppStrings.validationRequired : null,
                  hint: const Text(AppStrings.contactRelationshipHint),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.family_restroom_outlined),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const InfoNote(
                message: AppStrings.contactPrivacyNote,
                icon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish(RegisterDraft? draft) async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    // Simulacion del alta; aqui se enviaria draft + contacto al backend.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.home,
      (Route<dynamic> route) => false,
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    return null;
  }
}
