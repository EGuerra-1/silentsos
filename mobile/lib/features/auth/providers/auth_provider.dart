import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../datasource/auth_remote_datasource.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

/// Cadena DI de Auth: datasource -> repository -> service -> controller.
final authRemoteProvider = Provider<AuthRemoteDataSource>(
  (Ref ref) => AuthRemoteDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepository(ref.watch(authRemoteProvider)),
);

final authServiceProvider = Provider<AuthService>(
  (Ref ref) => AuthService(ref.watch(authRepositoryProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>(
  (Ref ref) => AuthController(ref.watch(authServiceProvider)),
);
