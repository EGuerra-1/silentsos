import '../datasource/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';

/// Adaptador entre negocio y fuente remota de autenticacion.
class AuthRepository {
  AuthRepository(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  /// Delega en datasource para obtener token/sesion.
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.login(email: email, password: password);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String cellphone,
    required String password,
  }) {
    return _remoteDataSource.register(
      fullName: fullName,
      email: email,
      cellphone: cellphone,
      password: password,
    );
  }

  Future<void> createEmergencyContact({
    required String fullName,
    required String cellphone,
    required String relationship,
    required String token,
  }) {
    return _remoteDataSource.createEmergencyContact(
      fullName: fullName,
      cellphone: cellphone,
      relationship: relationship,
      token: token,
    );
  }
}
