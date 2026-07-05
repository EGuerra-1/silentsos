import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/themes/app_theme.dart';

class SilentSosApp extends StatelessWidget {
  const SilentSosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentSOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
