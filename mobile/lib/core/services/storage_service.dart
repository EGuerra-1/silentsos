import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_config.dart';

/// Persistencia segura de credenciales/sesion.
abstract final class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _credentialsDateKey = 'credentials_date';
  static const String _themeModeKey = 'theme_mode';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getUserId() => _storage.read(key: _userIdKey);
  static Future<String?> getUserName() => _storage.read(key: _userNameKey);
  static Future<String?> getUserEmail() => _storage.read(key: _userEmailKey);
  static Future<String?> getUserRole() => _storage.read(key: _userRoleKey);
  static Future<String?> getCredentialsDate() =>
      _storage.read(key: _credentialsDateKey);

  // Preferencia de tema (no sensible; se conserva aunque se cierre sesion).
  static Future<String?> getThemeMode() => _storage.read(key: _themeModeKey);
  static Future<void> saveThemeMode(String value) =>
      _storage.write(key: _themeModeKey, value: value);

  static Future<void> saveCredentials({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    final String nowIso = DateTime.now().toIso8601String();
    await Future.wait(<Future<void>>[
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userNameKey, value: userName),
      _storage.write(key: _userEmailKey, value: userEmail),
      _storage.write(key: _userRoleKey, value: userRole),
      _storage.write(key: _credentialsDateKey, value: nowIso),
    ]);
  }

  static Future<void> clear() async {
    await Future.wait(<Future<void>>[
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userRoleKey),
      _storage.delete(key: _credentialsDateKey),
    ]);
  }

  /// Indica si existe sesion local vigente.
  static Future<bool> isRegistered() async {
    try {
      final String? token = await getToken();
      final String? userId = await getUserId();
      final String? userName = await getUserName();
      final String? credentialsDate = await getCredentialsDate();

      if (token == null ||
          userId == null ||
          userName == null ||
          credentialsDate == null) {
        return false;
      }

      final DateTime storedDate = DateTime.parse(credentialsDate);
      final int daysDifference = DateTime.now().difference(storedDate).inDays;

      if (daysDifference > AppConfig.tokenDurationDays) {
        await clear();
        return false;
      }
      return true;
    } catch (_) {
      await clear();
      return false;
    }
  }
}
