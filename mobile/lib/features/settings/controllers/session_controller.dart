import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';

/// Datos basicos del usuario en sesion, leidos del almacenamiento seguro.
class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  /// Inicial para el avatar (fallback "S" de SilentSOS).
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'S';
}

/// Expone el usuario guardado para pintar el encabezado de Ajustes.
final sessionUserProvider = FutureProvider<SessionUser>((Ref ref) async {
  final String name = await StorageService.getUserName() ?? 'Usuario';
  final String email = await StorageService.getUserEmail() ?? '';
  final String role = await StorageService.getUserRole() ?? 'user';
  return SessionUser(name: name, email: email, role: role);
});

/// Acciones de sesion (por ahora, cerrar sesion).
final sessionControllerProvider = Provider<SessionController>(
  (Ref ref) => SessionController(),
);

class SessionController {
  /// Borra credenciales locales; la navegacion la maneja la UI.
  Future<void> logout() => StorageService.clear();
}
