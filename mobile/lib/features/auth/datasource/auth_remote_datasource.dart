import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  /// Simula la llamada HTTP de login y devuelve la sesion remota.
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const AuthSessionModel(token: 'local-dev-token');
  }
}
