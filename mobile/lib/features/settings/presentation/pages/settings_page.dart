import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../controllers/settings_display_controller.dart';
import '../../models/emergency_contact_model.dart';
import '../../models/user_profile_model.dart';
import '../../providers/profile_provider.dart';
import '../widgets/settings_nav_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/theme_mode_selector.dart';

/// Tab Ajustes: perfil, contacto de emergencia, apariencia y cierre de sesion.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _openEditProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfileModel? currentProfile,
  ) async {
    final UserProfileModel? updated = await AppRouter.openEditProfile(
      context,
      profile: currentProfile,
    );
    if (updated == null) return;
    await ref.read(settingsDisplayProvider.notifier).applyProfile(updated);
  }

  Future<void> _openEditEmergencyContact(
    BuildContext context,
    WidgetRef ref,
    EmergencyContactModel? currentContact,
  ) async {
    final EmergencyContactModel? updated =
        await AppRouter.openEditEmergencyContact(
      context,
      contact: currentContact,
    );
    if (updated == null) return;
    ref.read(settingsDisplayProvider.notifier).applyEmergencyContact(updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SettingsDisplayData> display =
        ref.watch(settingsDisplayProvider);

    return AppPageShell(
      appBar: const CustomAppBar(
        title: AppStrings.settingsTitle,
        showBack: false,
      ),
      child: display.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (Object _, StackTrace __) => ErrorState(
          message: AppStrings.loadProfileError,
          onRetry: () => ref.read(settingsDisplayProvider.notifier).load(),
        ),
        data: (SettingsDisplayData data) {
          final SessionUser user = data.sessionUser;
          final EmergencyContactModel? contact = data.emergencyContact;

          return SingleChildScrollView(
            child: StaggeredColumn(
              children: <Widget>[
                const SizedBox(height: AppSpacing.sm),
                _ProfileCard(
                  user: user,
                  onTap: () => _openEditProfile(context, ref, data.profile),
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsSection(
                  title: AppStrings.settingsProfileSection,
                  child: Column(
                    children: <Widget>[
                      SettingsNavTile(
                        icon: Icons.person_outline,
                        title: AppStrings.settingsEditProfile,
                        subtitle: user.email,
                        onTap: () =>
                            _openEditProfile(context, ref, data.profile),
                      ),
                      Divider(
                        height: 1,
                        color: context.colors.outlineVariant.withOpacity(0.6),
                      ),
                      SettingsNavTile(
                        icon: Icons.favorite_border_rounded,
                        title: AppStrings.settingsEditEmergencyContact,
                        subtitle: contact == null
                            ? null
                            : '${contact.fullName} · ${contact.cellphone}',
                        onTap: () => _openEditEmergencyContact(
                          context,
                          ref,
                          contact,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SettingsSection(
                  title: AppStrings.settingsAppearance,
                  child: ThemeModeSelector(),
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsSection(
                  title: AppStrings.settingsAccountSection,
                  child: _LogoutTile(onTap: () => _confirmLogout(context, ref)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text(
                    'SilentSOS v1.0.0',
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: const Text(AppStrings.settingsLogoutConfirmTitle),
          content: const Text(AppStrings.settingsLogoutConfirmBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(AppStrings.settingsCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(AppStrings.settingsLogout),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(sessionControllerProvider).logout();
    ref.invalidate(settingsDisplayProvider);
    ref.invalidate(authControllerProvider);
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (Route<dynamic> route) => false,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.onTap,
  });

  final SessionUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    context.semantic.brandGradientStart,
                    context.semantic.brandGradientEnd,
                  ],
                ),
              ),
              child: Text(
                user.initial,
                style: context.text.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: context.text.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      user.email,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color danger = context.semantic.danger;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: <Widget>[
            Icon(Icons.logout_rounded, color: danger),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppStrings.settingsLogout,
                style: context.text.bodyMedium?.copyWith(color: danger),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: danger),
          ],
        ),
      ),
    );
  }
}
