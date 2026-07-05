import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_step_one_page.dart';
import '../../features/auth/presentation/pages/register_step_two_page.dart';
import '../../features/medical/models/medication_models.dart';
import '../../features/medical/models/user_disease_model.dart';
import '../../features/medical/presentation/pages/disease_form_page.dart';
import '../../features/medical/presentation/pages/medication_form_page.dart';
import '../../features/settings/models/emergency_contact_model.dart';
import '../../features/settings/models/user_profile_model.dart';
import '../../features/settings/presentation/pages/edit_emergency_contact_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
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
  static const String editProfile = '/settings/profile/edit';
  static const String editEmergencyContact = '/settings/emergency-contact/edit';

  /// Abre formulario de perfil con datos opcionales precargados.
  static Future<UserProfileModel?> openEditProfile(
    BuildContext context, {
    UserProfileModel? profile,
  }) {
    return Navigator.push<UserProfileModel>(
      context,
      AppPageRoute<UserProfileModel>(
        settings: RouteSettings(
          name: editProfile,
          arguments: profile,
        ),
        builder: (_) => EditProfilePage(initial: profile),
      ),
    );
  }

  /// Abre formulario de contacto de emergencia.
  static Future<EmergencyContactModel?> openEditEmergencyContact(
    BuildContext context, {
    EmergencyContactModel? contact,
  }) {
    return Navigator.push<EmergencyContactModel>(
      context,
      AppPageRoute<EmergencyContactModel>(
        settings: RouteSettings(
          name: editEmergencyContact,
          arguments: contact,
        ),
        builder: (_) => EditEmergencyContactPage(initial: contact),
      ),
    );
  }

  /// Abre formulario de medicamento con ruta tipada (evita cast en pushNamed).
  static Future<bool?> openMedicationForm(
    BuildContext context, {
    MedicationPlanModel? plan,
  }) {
    final bool isEdit = plan != null;
    return Navigator.push<bool>(
      context,
      AppPageRoute<bool>(
        settings: RouteSettings(
          name: isEdit ? editMedication : addMedication,
          arguments: plan,
        ),
        builder: (_) => MedicationFormPage(initial: plan),
      ),
    );
  }

  /// Abre formulario de enfermedad con ruta tipada (evita cast en pushNamed).
  static Future<bool?> openDiseaseForm(
    BuildContext context, {
    UserDiseaseModel? disease,
  }) {
    final bool isEdit = disease != null;
    return Navigator.push<bool>(
      context,
      AppPageRoute<bool>(
        settings: RouteSettings(
          name: isEdit ? editDisease : addDisease,
          arguments: disease,
        ),
        builder: (_) => DiseaseFormPage(initial: disease),
      ),
    );
  }

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
        return AppPageRoute<bool>(
          settings: settings,
          builder: (_) => const DiseaseFormPage(),
        );
      case editDisease:
        return AppPageRoute<bool>(
          settings: settings,
          builder: (_) => DiseaseFormPage(
            initial: settings.arguments as UserDiseaseModel?,
          ),
        );
      case addMedication:
        return AppPageRoute<bool>(
          settings: settings,
          builder: (_) => const MedicationFormPage(),
        );
      case editMedication:
        return AppPageRoute<bool>(
          settings: settings,
          builder: (_) => MedicationFormPage(
            initial: settings.arguments as MedicationPlanModel?,
          ),
        );
      case editProfile:
        return AppPageRoute<UserProfileModel>(
          settings: settings,
          builder: (_) => EditProfilePage(
            initial: settings.arguments as UserProfileModel?,
          ),
        );
      case editEmergencyContact:
        return AppPageRoute<EmergencyContactModel>(
          settings: settings,
          builder: (_) => EditEmergencyContactPage(
            initial: settings.arguments as EmergencyContactModel?,
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
