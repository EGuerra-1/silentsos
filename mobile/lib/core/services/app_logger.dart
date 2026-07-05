import 'dart:developer' as dev;

abstract final class AppLogger {
  static void info(String message) {
    dev.log(message, name: 'SilentSOS');
  }

  static void warning(String message) {
    dev.log(message, name: 'SilentSOS', level: 900);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: 'SilentSOS',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
