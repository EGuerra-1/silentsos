import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/emergency_relationship_options.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../entities/auth_user.dart';
import '../../models/register_draft.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

const List<String> _relationshipOptions = EmergencyRelationshipOptions.values;

/// Registro paso 2 de Stitch: badge "PASO 2 DE 2" con progreso completo,
/// icono de corazon, campos etiquetados con iconos y CTA fijo.
class RegisterStepTwoPage extends ConsumerStatefulWidget {
  const RegisterStepTwoPage({super.key});

  @override
  ConsumerState<RegisterStepTwoPage> createState() => _RegisterStepTwoPageState();
}

class _RegisterStepTwoPageState extends ConsumerState<RegisterStepTwoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactPhoneCtrl = TextEditingController();
  String? _relationship;
  String? _apiError;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

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
          isLoading: authState.isLoading,
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
              if (_apiError != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                InfoNote(
                  message: _apiError!,
                  icon: Icons.error_outline,
                  tone: InfoNoteTone.error,
                ),
              ],
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
    if (draft == null) {
      setState(() => _apiError = 'No se encontro la informacion del paso 1.');
      return;
    }
    if (_relationship == null) return;

    setState(() => _apiError = null);

    await ref.read(authControllerProvider.notifier).registerWithEmergencyContact(
          fullName: draft.fullName,
          email: draft.email,
          cellphone: draft.phone,
          password: draft.password,
          emergencyFullName: _contactNameCtrl.text.trim(),
          emergencyCellphone: _contactPhoneCtrl.text.trim(),
          emergencyRelationship: _relationship!,
        );

    final AsyncValue<AuthUser?> state = ref.read(authControllerProvider);
    if (!mounted) return;
    state.when(
      data: (AuthUser? user) {
        if (user == null) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (Route<dynamic> route) => false,
        );
      },
      loading: () {},
      error: (Object error, StackTrace _) {
        AppLogger.error('[UI][RegisterStep2] error capturado', error: error);
        setState(() => _apiError = _prettyError(error));
      },
    );
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
    return raw;
  }
}
