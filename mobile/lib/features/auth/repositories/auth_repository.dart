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
}
