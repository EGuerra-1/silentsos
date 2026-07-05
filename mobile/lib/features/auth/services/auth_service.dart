import '../../../core/services/storage_service.dart';
import '../entities/auth_user.dart';
import '../models/auth_session_model.dart';
import '../repositories/auth_repository.dart';

/// Regla de negocio de autenticacion (capa de aplicacion).
class AuthService {
  AuthService(this._repository);

  final AuthRepository _repository;

  /// Login y mapeo de sesion remota a entidad de dominio.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final AuthSessionModel session = await _repository.login(
      email: email,
      password: password,
    );

    await StorageService.saveCredentials(
      token: session.token,
      userId: session.user.id,
      userName: session.user.fullName,
      userEmail: session.user.email,
      userRole: session.user.role,
    );
    return session.user;
  }

  /// Registro + login + creacion de contacto de emergencia.
  Future<AuthUser> registerWithEmergencyContact({
    required String fullName,
    required String email,
    required String cellphone,
    required String password,
    required String emergencyFullName,
    required String emergencyCellphone,
    required String emergencyRelationship,
  }) async {
    await _repository.register(
      fullName: fullName,
      email: email,
      cellphone: cellphone,
      password: password,
    );

    final AuthSessionModel session = await _repository.login(
      email: email,
      password: password,
    );

    await _repository.createEmergencyContact(
      fullName: emergencyFullName,
      cellphone: emergencyCellphone,
      relationship: emergencyRelationship,
      token: session.token,
    );

    await StorageService.saveCredentials(
      token: session.token,
      userId: session.user.id,
      userName: session.user.fullName,
      userEmail: session.user.email,
      userRole: session.user.role,
      userCellphone: cellphone,
    );
    return session.user;
  }
}
