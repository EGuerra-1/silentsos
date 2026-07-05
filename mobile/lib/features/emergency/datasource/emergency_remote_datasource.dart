import '../../../core/exceptions/app_exception.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_logger.dart';
import '../models/emergency_model.dart';

/// Cliente HTTP del modulo de emergencias.
class EmergencyRemoteDataSource {
  Future<EmergencyModel> createUrgency({
    required EmergencyType type,
    required double latitude,
    required double longitude,
    String? address,
    String? priority,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'type': type.apiValue,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
      if (priority != null && priority.trim().isNotEmpty) 'priority': priority.trim(),
    };

    final Map<String, dynamic> result = await ApiService.sendData(
      '/emergencies/urgency',
      'POST',
      payload,
    );

    return _parseSingle(result);
  }

  Future<EmergencyModel> fetchById(String id) async {
    final Map<String, dynamic> result =
        await ApiService.fetchData('/emergencies/$id');
    return _parseSingle(result);
  }

  EmergencyModel _parseSingle(Map<String, dynamic> result) {
    if (result['ok'] != true) {
      AppLogger.error(
        '[Emergency] request fallo | response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }

    final Map<String, dynamic> body =
        result['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> data =
        body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return EmergencyModel.fromJson(data);
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
    return 'No fue posible procesar la emergencia.';
  }
}
