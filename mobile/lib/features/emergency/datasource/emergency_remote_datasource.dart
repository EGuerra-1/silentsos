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

  Future<EmergencyModel> createContextual({
    required String frontImagePath,
    required String backImagePath,
    required double latitude,
    required double longitude,
    String? address,
    String? contextText,
  }) async {
    final Map<String, String> fields = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'call_mode': 'single_context',
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
      if (contextText != null && contextText.trim().isNotEmpty)
        'context_text': contextText.trim(),
    };

    final Map<String, dynamic> result = await ApiService.sendMultipart(
      '/emergencies/contextual',
      fields: fields,
      files: <ApiMultipartFile>[
        ApiMultipartFile.fromPath(field: 'front_image', path: frontImagePath),
        ApiMultipartFile.fromPath(field: 'back_image', path: backImagePath),
      ],
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

    final dynamic rawBody = result['body'];
    if (rawBody is! Map) {
      AppLogger.error('[Emergency] body invalido | type:${rawBody.runtimeType}');
      throw const AppException('Respuesta invalida del servidor.');
    }

    final Map<String, dynamic> body = Map<String, dynamic>.from(rawBody);

    if (body['success'] == false) {
      throw AppException(_extractErrorMessage(result));
    }

    final dynamic rawData = body['data'];
    if (rawData is! Map) {
      AppLogger.error('[Emergency] data invalido | type:${rawData.runtimeType}');
      throw const AppException('Datos de emergencia no disponibles.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
    return EmergencyModel.fromJson(data);
  }

  String _extractErrorMessage(Map<String, dynamic> result) {
    final dynamic body = result['body'];
    if (body is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(body);
      final String error = (map['error'] ?? '').toString();
      if (error.isNotEmpty) return error;
      final String message = (map['message'] ?? '').toString();
      if (message.isNotEmpty) return message;
    }
    final String fallback = (result['error'] ?? '').toString();
    if (fallback.isNotEmpty) return fallback;
    return 'No fue posible procesar la emergencia.';
  }
}
