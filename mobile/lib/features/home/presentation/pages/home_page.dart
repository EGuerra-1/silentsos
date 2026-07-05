import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/animations/staggered_column.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../entities/home_alert_entity.dart';
import '../widgets/status_chip.dart';
import '../../providers/home_provider.dart';

/// Tab Emergencias: hero con acceso rapido SOS + panel de alertas activas.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HomeAlertEntity>> state =
        ref.watch(homeControllerProvider);

    return AppPageShell(
      appBar: const CustomAppBar(title: 'Emergencias', showBack: false),
      child: state.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (Object error, StackTrace stackTrace) => ErrorState(
          message: 'No fue posible cargar tu panel.',
          onRetry: () => ref.read(homeControllerProvider.notifier).load(),
        ),
        data: (List<HomeAlertEntity> alerts) {
          return ListView(
            children: <Widget>[
              const _EmergenciesHero(),
              const SizedBox(height: AppSpacing.lg),
              if (alerts.isEmpty)
                const EmptyState(
                  message: 'No hay alertas activas. Tu red de seguridad esta lista.',
                  icon: Icons.shield_outlined,
                )
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xs,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    'MONITOREO',
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                ...List<Widget>.generate(alerts.length, (int index) {
                  final HomeAlertEntity alert = alerts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == alerts.length - 1
                          ? AppSpacing.xxl
                          : AppSpacing.md,
                    ),
                    child: FadeSlideIn(
                      delay: AppDuration.stagger * index,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: alert.isActive
                                        ? context.colors.secondaryContainer
                                        : context.colors.errorContainer,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Icon(
                                    alert.isActive
                                        ? Icons.verified_user_rounded
                                        : Icons.warning_amber_rounded,
                                    color: alert.isActive
                                        ? context.colors.onSecondaryContainer
                                        : context.colors.onErrorContainer,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: context.text.labelLarge,
                                  ),
                                ),
                                StatusChip(isActive: alert.isActive),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              alert.subtitle,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Banner principal con gradiente de marca y boton SOS destacado.
class _EmergenciesHero extends StatelessWidget {
  const _EmergenciesHero();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return FadeSlideIn(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              context.semantic.brandGradientStart,
              context.semantic.brandGradientEnd,
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.primaryContainer.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.shield_outlined, color: colors.onPrimary, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tu red de seguridad',
                      style: context.text.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Activa una alerta SOS y notificaremos a tu contacto de '
                'emergencia al instante.',
                style: context.text.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.touchTargetMin,
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.onPrimary,
                    foregroundColor: colors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  icon: const Icon(Icons.sos_rounded, size: 28),
                  label: Text(
                    'Activar SOS',
                    style: context.text.labelLarge?.copyWith(
                      color: colors.primaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
