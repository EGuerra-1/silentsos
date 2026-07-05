import '../entities/auth_user.dart';
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
    await _repository.login(email: email, password: password);
    return AuthUser(email: email, fullName: 'Usuario SilentSOS');
  }
}
