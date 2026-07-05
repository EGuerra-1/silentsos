import 'dart:developer' as dev;

abstract final class AppLogger {
  static void info(String message) {
    dev.log(message, name: 'SilentSOS');
  }
}
