import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/brand_badge.dart';
import '../../../../shared/widgets/info_note.dart';
import '../../../../shared/widgets/password_text_field.dart';
import '../../entities/auth_user.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

/// Login de Stitch: insignia de escudo, titulo indigo centrado, tarjeta
/// con formulario y CTA "Entrar".
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identityCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _hasAuthError = false;
  String _authErrorMessage = AppStrings.loginError;

  @override
  void dispose() {
    _identityCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthUser?> state = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AuthUser?>>(authControllerProvider,
        (_, AsyncValue<AuthUser?> next) {
      if (next.hasError) {
        AppLogger.error('[UI][Login] error capturado', error: next.error);
        setState(() {
          _hasAuthError = true;
          _authErrorMessage = _prettyError(next.error);
        });
      } else if (next.hasValue && next.value != null) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    });

    return AppPageShell(
      child: Center(
        child: SingleChildScrollView(
          child: StaggeredColumn(
            children: <Widget>[
              const Center(
                child: BrandBadge(icon: Icons.shield_outlined, size: 56),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthHeader(
                title: AppStrings.loginTitle,
                subtitle: AppStrings.loginSubtitle,
                titleColor: context.colors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      AppTextField(
                        label: AppStrings.loginEmailLabel,
                        controller: _identityCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                        validator: _validateIdentity,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PasswordTextField(
                        label: AppStrings.loginPasswordLabel,
                        controller: _passwordCtrl,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onFieldSubmitted: (_) => _submit(state.isLoading),
                      ),
                      AnimatedSize(
                        duration: AppDuration.normal,
                        curve: AppDuration.easeOut,
                        child: _hasAuthError
                            ? Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.md),
                                child: InfoNote(
                                  message: _authErrorMessage,
                                  icon: Icons.error_outline,
                                  tone: InfoNoteTone.error,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: AppStrings.loginSubmit,
                        isLoading: state.isLoading,
                        onPressed: () => _submit(state.isLoading),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _LegalFooter(),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: AppStrings.loginCreateAccount,
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRouter.registerStepOne,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(bool isLoading) {
    if (isLoading) return;
    setState(() {
      _hasAuthError = false;
      _authErrorMessage = AppStrings.loginError;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(authControllerProvider.notifier).login(
          email: _identityCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  String? _validateIdentity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    final RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value.trim())) return AppStrings.validationEmail;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.validationRequired;
    if (value.length < 8) return AppStrings.validationPasswordLength;
    return null;
  }

  String _prettyError(Object? error) {
    if (error == null) return AppStrings.loginError;
    final String raw = error.toString();
    const String prefix = 'AppException(';
    if (raw.startsWith(prefix) && raw.endsWith(')')) {
      return raw.substring(prefix.length, raw.length - 1);
    }
    return raw;
  }
}

/// "Al continuar, aceptas nuestros Terminos y Privacidad." con enlaces.
class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final TextStyle? link = base?.copyWith(
      color: context.colors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          const TextSpan(text: AppStrings.loginLegalPrefix),
          TextSpan(text: 'Terminos', style: link),
          const TextSpan(text: ' y '),
          TextSpan(text: 'Privacidad', style: link),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
