/// Configuracion central de entorno/API.
abstract final class AppConfig {
  /// API local de SilentSOS.
  ///
  /// Nota: en emulador Android normalmente se usa `http://10.0.2.2:4000`.
  static const String baseUrl = 'https://hackton.danielmorales.tech/api';

  /// Vigencia de la sesion local (alineada a JWT de backend).
  static const int tokenDurationDays = 30;
}
