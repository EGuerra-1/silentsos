import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuracion central de entorno/API, cargada desde `.env`.
abstract final class AppConfig {
  static const String _defaultBaseUrl = 'http://localhost:4000/api';
  static const int _defaultTokenDurationDays = 30;

  /// Debe llamarse en `main()` antes de `runApp`.
  static Future<void> load() => dotenv.load(fileName: '.env');

  /// URL base de la API (incluye prefijo `/api` si aplica).
  static String get baseUrl =>
      dotenv.env['BASE_URL']?.trim().isNotEmpty == true
          ? dotenv.env['BASE_URL']!.trim()
          : _defaultBaseUrl;

  /// Vigencia de la sesion local (alineada a JWT de backend).
  static int get tokenDurationDays {
    final int? parsed = int.tryParse(
      dotenv.env['TOKEN_DURATION_DAYS']?.trim() ?? '',
    );
    return parsed ?? _defaultTokenDurationDays;
  }
}
