import '../../../core/exceptions/app_exception.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_logger.dart';
import '../models/emergency_contact_model.dart';
import '../models/user_profile_model.dart';

/// Cliente HTTP para perfil y contacto de emergencia.
class ProfileRemoteDataSource {
  Future<UserProfileModel> fetchUserById(String userId) async {
    final Map<String, dynamic> result =
        await ApiService.fetchData('/users/$userId');
    return _parseSingle(result, UserProfileModel.fromJson);
  }

  Future<UserProfileModel> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? cellphone,
    String? password,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (fullName != null) payload['full_name'] = fullName;
    if (email != null) payload['email'] = email;
    if (cellphone != null) payload['cellphone'] = cellphone;
    if (password != null && password.isNotEmpty) payload['password'] = password;

    final Map<String, dynamic> result = await ApiService.sendData(
      '/users/$userId',
      'PUT',
      payload,
    );
    return _parseSingle(result, UserProfileModel.fromJson);
  }

  Future<List<EmergencyContactModel>> fetchEmergencyContacts() async {
    final Map<String, dynamic> result =
        await ApiService.fetchData('/emergency_contacts');
    return _parseList(result, EmergencyContactModel.fromJson);
  }

  Future<EmergencyContactModel> updateEmergencyContact({
    required String id,
    String? fullName,
    String? cellphone,
    String? relationship,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (fullName != null) payload['full_name'] = fullName;
    if (cellphone != null) payload['cellphone'] = cellphone;
    if (relationship != null) payload['relationship'] = relationship;

    final Map<String, dynamic> result = await ApiService.sendData(
      '/emergency_contacts/$id',
      'PUT',
      payload,
    );
    return _parseSingle(result, EmergencyContactModel.fromJson);
  }

  List<T> _parseList<T>(
    Map<String, dynamic> result,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (result['ok'] != true) {
      AppLogger.error(
        '[Profile] list fallo | response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }

    final Map<String, dynamic> body =
        result['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> data = body['data'] as List<dynamic>? ?? <dynamic>[];
    return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  T _parseSingle<T>(
    Map<String, dynamic> result,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (result['ok'] != true) {
      AppLogger.error(
        '[Profile] write fallo | response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }

    final Map<String, dynamic> body =
        result['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> data =
        body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return fromJson(data);
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
