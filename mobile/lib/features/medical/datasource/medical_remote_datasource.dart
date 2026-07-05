import '../../../core/exceptions/app_exception.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_logger.dart';
import '../models/disease_catalog_model.dart';
import '../models/medication_models.dart';
import '../models/user_disease_model.dart';
import '../utils/medical_formatters.dart';

/// Cliente HTTP del modulo medico. Todos los endpoints requieren Bearer token.
class MedicalRemoteDataSource {
  Future<List<DiseaseCatalogModel>> fetchDiseaseCatalog() async {
    final Map<String, dynamic> result =
        await ApiService.fetchData('/medical/disease_catalogs');
    return _parseList(result, DiseaseCatalogModel.fromJson);
  }

  Future<List<UserDiseaseModel>> fetchUserDiseases() async {
    final Map<String, dynamic> result =
        await ApiService.fetchData('/medical/user_diseases');
    return _parseList(result, UserDiseaseModel.fromJson);
  }

  Future<UserDiseaseModel> createUserDisease({
    required String diseaseCatalogId,
    String? notes,
    DateTime? diagnosedAt,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'disease_catalog_id': diseaseCatalogId,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (diagnosedAt != null)
        'diagnosed_at': MedicalFormatters.formatDate(diagnosedAt),
    };

    final Map<String, dynamic> result = await ApiService.sendData(
      '/medical/user_diseases',
      'POST',
      payload,
    );
    return _parseSingle(result, UserDiseaseModel.fromJson);
  }

  Future<UserDiseaseModel> updateUserDisease({
    required String id,
    required String diseaseCatalogId,
    String? notes,
    DateTime? diagnosedAt,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'disease_catalog_id': diseaseCatalogId,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (diagnosedAt != null)
        'diagnosed_at': MedicalFormatters.formatDate(diagnosedAt),
    };

    final Map<String, dynamic> result = await ApiService.sendData(
      '/medical/user_diseases/$id',
      'PUT',
      payload,
    );
    return _parseSingle(result, UserDiseaseModel.fromJson);
  }

  Future<List<MedicationPlanModel>> fetchMedications() async {
    final Map<String, dynamic> result =
        await ApiService.fetchData('/medical/medications');
    return _parseList(result, MedicationPlanModel.fromJson);
  }

  Future<MedicationPlanModel> createMedication(
    Map<String, dynamic> payload,
  ) async {
    final Map<String, dynamic> result = await ApiService.sendData(
      '/medical/medications',
      'POST',
      payload,
    );
    return _parseSingle(result, MedicationPlanModel.fromJson);
  }

  Future<MedicationPlanModel> updateMedication({
    required String planId,
    required Map<String, dynamic> payload,
  }) async {
    final Map<String, dynamic> result = await ApiService.sendData(
      '/medical/medications/$planId',
      'PUT',
      payload,
    );
    return _parseSingle(result, MedicationPlanModel.fromJson);
  }

  Future<List<PendingMedicationModel>> fetchPendingToday({DateTime? date}) async {
    final String endpoint = date == null
        ? '/medical/medications/pending-today'
        : '/medical/medications/pending-today?date=${MedicalFormatters.formatDate(date)}';

    final Map<String, dynamic> result = await ApiService.fetchData(endpoint);
    if (result['ok'] != true) {
      AppLogger.error(
        '[Medical] pending-today fallo | response:${result['body'] ?? result['error']}',
      );
      throw AppException(_extractErrorMessage(result));
    }

    final Map<String, dynamic> body =
        result['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final dynamic data = body['data'];

    // El backend devuelve { date, total_pending, pending: [...] }.
    if (data is Map<String, dynamic>) {
      return PendingTodayResponse.fromJson(data).pending;
    }

    if (data is List<dynamic>) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(PendingMedicationModel.fromJson)
          .toList();
    }

    return const <PendingMedicationModel>[];
  }

  Future<MedicationConsumptionModel> registerConsumption({
    required String medicationPlanId,
    String? scheduledTime,
    DateTime? consumedAt,
    String? status,
    String? observations,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'medication_plan_id': medicationPlanId,
      if (scheduledTime != null && scheduledTime.isNotEmpty)
        'scheduled_time': MedicalFormatters.toApiTime(scheduledTime),
      if (consumedAt != null)
        'consumed_at': MedicalFormatters.toApiDateTime(consumedAt),
      if (status != null && status.isNotEmpty) 'status': status,
      if (observations != null && observations.trim().isNotEmpty)
        'observations': observations.trim(),
    };

    final Map<String, dynamic> result = await ApiService.sendData(
      '/medical/consumptions',
      'POST',
      payload,
    );
    return _parseSingle(result, MedicationConsumptionModel.fromJson);
  }

  Future<List<MedicationConsumptionModel>> fetchConsumptions({
    DateTime? from,
    DateTime? to,
    String? status,
  }) async {
    final Map<String, String> query = <String, String>{};
    if (from != null) {
      query['from'] = MedicalFormatters.toApiDateTime(from);
    }
    if (to != null) query['to'] = MedicalFormatters.toApiDateTime(to);
    if (status != null && status.isNotEmpty) query['status'] = status;

    final String endpoint = query.isEmpty
        ? '/medical/consumptions'
        : '/medical/consumptions?${Uri(queryParameters: query).query}';

    final Map<String, dynamic> result = await ApiService.fetchData(endpoint);
    return _parseList(result, MedicationConsumptionModel.fromJson);
  }

  List<T> _parseList<T>(
    Map<String, dynamic> result,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (result['ok'] != true) {
      AppLogger.error('[Medical] list fallo | response:${result['body'] ?? result['error']}');
      throw AppException(_extractErrorMessage(result));
    }

    final Map<String, dynamic> body =
        result['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> data = body['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }

  T _parseSingle<T>(
    Map<String, dynamic> result,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (result['ok'] != true) {
      AppLogger.error('[Medical] write fallo | response:${result['body'] ?? result['error']}');
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
