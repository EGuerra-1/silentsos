import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../controllers/session_controller.dart';
import '../widgets/settings_section.dart';
import '../widgets/theme_mode_selector.dart';

/// Tab Ajustes: perfil, apariencia (tema) y cierre de sesion.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SessionUser> user = ref.watch(sessionUserProvider);

    return AppPageShell(
      appBar: const CustomAppBar(title: 'Ajustes', showBack: false),
      child: SingleChildScrollView(
        child: StaggeredColumn(
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),
            _ProfileCard(user: user),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSection(
              title: 'Apariencia',
              child: ThemeModeSelector(),
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: 'Cuenta',
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
          title: const Text('Cerrar sesion'),
          content: const Text(
            'Se cerrara tu sesion en este dispositivo. Deberas iniciar '
            'sesion de nuevo para continuar.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cerrar sesion'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(sessionControllerProvider).logout();
    ref.invalidate(sessionUserProvider);
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
  const _ProfileCard({required this.user});

  final AsyncValue<SessionUser> user;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final SessionUser? data = user.valueOrNull;

    return AppCard(
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
              data?.initial ?? 'S',
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
                  data?.name ?? 'Usuario',
                  style: context.text.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((data?.email ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    data!.email,
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
        ],
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
                'Cerrar sesion',
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
