import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_duration.dart';

final splashControllerProvider = Provider<SplashController>(
  (Ref ref) => SplashController(),
);

/// Controla el tiempo de permanencia del splash antes de ir a Login.
class SplashController {
  Future<void> waitForBoot() async {
    await Future<void>.delayed(AppDuration.splashHold);
  }
}
