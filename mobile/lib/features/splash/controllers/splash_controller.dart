import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_duration.dart';
import '../../../core/services/storage_service.dart';

final splashControllerProvider = Provider<SplashController>(
  (Ref ref) => SplashController(),
);

/// Controla el tiempo de permanencia del splash antes de ir a Login.
class SplashController {
  Future<void> waitForBoot() async {
    await Future<void>.delayed(AppDuration.splashHold);
  }

  /// Determina si se puede abrir Home directamente con sesion vigente.
  Future<bool> hasActiveSession() => StorageService.isRegistered();
}
