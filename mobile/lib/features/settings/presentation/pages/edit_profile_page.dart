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
import '../../../../shared/widgets/password_text_field.dart';
import '../../controllers/session_controller.dart';
import '../../models/user_profile_model.dart';
import '../../providers/profile_provider.dart';

/// Formulario para editar el perfil del usuario autenticado.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, this.initial});

  final UserProfileModel? initial;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  String? _apiError;
  String? _loadError;
  bool _isSaving = false;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _applyProfile(widget.initial!);
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final UserProfileModel profile = await ref
          .read(profileServiceProvider)
          .getCurrentUserProfile();
      if (!mounted) return;
      setState(() => _applyProfile(profile));
    } catch (error) {
      AppLogger.error('[Profile] load user fallo', error: error);
      if (!mounted) return;
      setState(() => _loadError = AppStrings.loadProfileError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyProfile(UserProfileModel profile) {
    _fullNameCtrl.text = profile.fullName;
    _phoneCtrl.text = profile.cellphone;
    _emailCtrl.text = profile.email;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      appBar: const CustomAppBar(title: AppStrings.editProfileTitle),
      bottomBar: _loadError == null && !_isLoading
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
          ? Center(child: Text(_loadError!, textAlign: TextAlign.center))
          : SingleChildScrollView(
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
                      AppStrings.editProfileSubtitle,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      hint: AppStrings.registerFullName,
                      controller: _fullNameCtrl,
                      textInputAction: TextInputAction.next,
                      maxLength: 250,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: _required,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      hint: AppStrings.registerPhone,
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 20,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: _required,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      hint: AppStrings.registerEmail,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      validator: _email,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PasswordTextField(
                      hint: AppStrings.editProfilePasswordHint,
                      controller: _passwordCtrl,
                      textInputAction: TextInputAction.done,
                      validator: _optionalPassword,
                      onFieldSubmitted: (_) => _save(),
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
    setState(() {
      _apiError = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(profileServiceProvider)
          .updateCurrentUserProfile(
            fullName: _fullNameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            cellphone: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text.trim().isEmpty
                ? null
                : _passwordCtrl.text,
          );

      ref.invalidate(userProfileProvider);
      ref.invalidate(sessionUserProvider);

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      AppLogger.error('[Profile] update user fallo', error: error);
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

  String? _email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    final RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value.trim())) return AppStrings.validationEmail;
    return null;
  }

  String? _optionalPassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) return AppStrings.validationPasswordLength;
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
