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
import '../../../../shared/widgets/brand_badge.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/password_text_field.dart';
import '../../models/register_draft.dart';
import '../widgets/auth_header.dart';

/// Registro paso 1: app bar con progreso al 50%, encabezado con insignia
/// animada, campos con iconos y entrada escalonada, CTA fijo con nota de
/// cifrado.
class RegisterStepOnePage extends StatefulWidget {
  const RegisterStepOnePage({super.key});

  @override
  State<RegisterStepOnePage> createState() => _RegisterStepOnePageState();
}

class _RegisterStepOnePageState extends State<RegisterStepOnePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

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
      appBar: const CustomAppBar(
        title: AppStrings.registerStepOneBadge,
        progress: 0.5,
      ),
      bottomBar: FadeSlideIn(
        delay: AppDuration.stagger * 6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppButton(
              label: AppStrings.registerNextStep,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: _continue,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _EncryptedCaption(),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: StaggeredColumn(
            children: <Widget>[
              const SizedBox(height: AppSpacing.lg),
              const Center(
                child: BrandBadge(
                  icon: Icons.badge_outlined,
                  style: BrandBadgeStyle.soft,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthHeader(
                title: AppStrings.registerStepOneTitleEs,
                subtitle: AppStrings.registerStepOneSubtitle,
              ),
              const SizedBox(height: AppSpacing.xl),
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
                hint: AppStrings.registerPassword,
                controller: _passwordCtrl,
                textInputAction: TextInputAction.done,
                validator: _password,
                onFieldSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final RegisterDraft draft = RegisterDraft(
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    Navigator.pushNamed(context, AppRouter.registerStepTwo, arguments: draft);
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

  String? _password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.validationRequired;
    if (value.length < 8) return AppStrings.validationPasswordLength;
    return null;
  }
}

/// Caption "Cifrado de extremo a extremo" con candado, bajo el CTA.
class _EncryptedCaption extends StatelessWidget {
  const _EncryptedCaption();

  @override
  Widget build(BuildContext context) {
    final Color color = context.colors.onSurfaceVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.lock_outline, size: 14, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          AppStrings.registerEncrypted,
          style: context.text.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
