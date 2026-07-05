import '../../../core/exceptions/app_exception.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_logger.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  /// Login real contra `POST /auth/login`.
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> result = await ApiService.sendData(
      '/auth/login',
      'POST',
      <String, dynamic>{'email': email, 'password': password},
      authRequired: false,
    );

    if (result['ok'] != true) {
      AppLogger.error(
        '[Auth] login fallo para email:$email | response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }

    final Map<String, dynamic> body =
        result['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> data =
        body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return AuthSessionModel.fromJson(data);
  }

  /// Registro real contra `POST /auth/register`.
  Future<void> register({
    required String fullName,
    required String email,
    required String cellphone,
    required String password,
  }) async {
    final Map<String, dynamic> result = await ApiService.sendData(
      '/auth/register',
      'POST',
      <String, dynamic>{
        'full_name': fullName,
        'email': email,
        'cellphone': cellphone,
        'password': password,
      },
      authRequired: false,
    );

    if (result['ok'] != true) {
      AppLogger.error(
        '[Auth] register fallo para email:$email | response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }
  }

  /// Alta de contacto contra `POST /emergency_contacts`.
  Future<void> createEmergencyContact({
    required String fullName,
    required String cellphone,
    required String relationship,
    required String token,
  }) async {
    final Map<String, dynamic> result = await ApiService.sendData(
      '/emergency_contacts',
      'POST',
      <String, dynamic>{
        'full_name': fullName,
        'cellphone': cellphone,
        'relationship': relationship,
      },
      authRequired: true,
      tokenOverride: token,
    );

    if (result['ok'] != true) {
      AppLogger.error(
        '[Auth] createEmergencyContact fallo para cellphone:$cellphone '
        '| response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }
  }

  String _extractErrorMessage(Map<String, dynamic> result) {
    final dynamic body = result['body'];
    if (body is Map<String, dynamic>) {
      final String error = (body['error'] ?? '').toString();
      if (error.isNotEmpty) return error;
      final String message = (body['message'] ?? '').toString();
      if (message.isNotEmpty) return message;
    }
    final String fallback = (result['error'] ?? '').toString();
    if (fallback.isNotEmpty) return fallback;
    return 'Ocurrio un error al comunicarse con el servidor.';
  }
}
