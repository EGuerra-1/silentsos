import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_step_one_page.dart';
import '../../features/auth/presentation/pages/register_step_two_page.dart';
import '../../features/medical/models/medication_models.dart';
import '../../features/medical/models/user_disease_model.dart';
import '../../features/medical/presentation/pages/disease_form_page.dart';
import '../../features/medical/presentation/pages/medication_form_page.dart';
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
  static const String addDisease = '/medical/diseases/add';
  static const String editDisease = '/medical/diseases/edit';
  static const String addMedication = '/medical/medications/add';
  static const String editMedication = '/medical/medications/edit';

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
      case addDisease:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const DiseaseFormPage(),
        );
      case editDisease:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => DiseaseFormPage(
            initial: settings.arguments as UserDiseaseModel?,
          ),
        );
      case addMedication:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => const MedicationFormPage(),
        );
      case editMedication:
        return AppPageRoute<void>(
          settings: settings,
          builder: (_) => MedicationFormPage(
            initial: settings.arguments as MedicationPlanModel?,
          ),
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
