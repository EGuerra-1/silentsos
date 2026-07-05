import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/themes/app_theme.dart';
import 'features/settings/controllers/theme_mode_controller.dart';

class SilentSosApp extends ConsumerWidget {
  const SilentSosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El modo de tema es reactivo: cambiarlo en Ajustes actualiza toda la app.
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      title: 'SilentSOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
