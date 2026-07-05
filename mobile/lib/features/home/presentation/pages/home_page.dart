import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/animations/fade_slide_in.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../entities/home_alert_entity.dart';
import '../widgets/status_chip.dart';
import '../../providers/home_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HomeAlertEntity>> state =
        ref.watch(homeControllerProvider);

    return AppPageShell(
      appBar: const CustomAppBar(title: 'Inicio', showBack: false),
      child: state.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (Object error, StackTrace stackTrace) => ErrorState(
          message: 'No fue posible cargar tu panel.',
          onRetry: () => ref.read(homeControllerProvider.notifier).load(),
        ),
        data: (List<HomeAlertEntity> alerts) {
          if (alerts.isEmpty) {
            return const EmptyState(message: 'No hay alertas disponibles.');
          }

          return ListView.separated(
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final HomeAlertEntity alert = alerts[index];
              return FadeSlideIn(
                delay: AppDuration.stagger * index,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            alert.isActive
                                ? Icons.verified_user
                                : Icons.warning_amber,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              alert.title,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          StatusChip(isActive: alert.isActive),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        alert.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
