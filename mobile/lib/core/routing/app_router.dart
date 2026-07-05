import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_step_one_page.dart';
import '../../features/auth/presentation/pages/register_step_two_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_page_route.dart';

abstract final class AppRouter {
  // Rutas centralizadas para evitar strings duplicados en la app.
  static const String splash = '/';
  static const String login = '/login';
  static const String registerStepOne = '/register-step-1';
  static const String registerStepTwo = '/register-step-2';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Punto unico de navegacion con transiciones animadas homogeneas.
    switch (settings.name) {
      case splash:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashPage(),
        );
      case login:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case registerStepOne:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterStepOnePage(),
        );
      case registerStepTwo:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterStepTwoPage(),
        );
      case home:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const MainShellPage(),
        );
      default:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
