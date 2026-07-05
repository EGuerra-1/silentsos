import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/auth_user.dart';
import '../services/auth_service.dart';

/// Orquesta estado de login para la UI (loading, data, error).
class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController(this._service) : super(const AsyncValue.data(null));

  final AuthService _service;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Exponemos loading/data/error con AsyncValue para simplificar la UI.
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<AuthUser?>(
      () => _service.login(email: email, password: password),
    );
  }
}
