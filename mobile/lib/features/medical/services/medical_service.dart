import '../models/disease_catalog_model.dart';
import '../models/medication_models.dart';
import '../models/user_disease_model.dart';
import '../repositories/medical_repository.dart';

/// Reglas de negocio del modulo medico expuestas a los controllers.
class MedicalService {
  MedicalService(this._repository);

  final MedicalRepository _repository;

  Future<List<DiseaseCatalogModel>> getDiseaseCatalog() =>
      _repository.getDiseaseCatalog();

  Future<List<UserDiseaseModel>> getUserDiseases() =>
      _repository.getUserDiseases();

  Future<UserDiseaseModel> saveUserDisease({
    String? id,
    required String diseaseCatalogId,
    String? notes,
    DateTime? diagnosedAt,
  }) {
    if (id == null) {
      return _repository.createUserDisease(
        diseaseCatalogId: diseaseCatalogId,
        notes: notes,
        diagnosedAt: diagnosedAt,
      );
    }
    return _repository.updateUserDisease(
      id: id,
      diseaseCatalogId: diseaseCatalogId,
      notes: notes,
      diagnosedAt: diagnosedAt,
    );
  }

  Future<List<MedicationPlanModel>> getMedications() =>
      _repository.getMedications();

  Future<MedicationPlanModel> saveMedication({
    String? planId,
    required Map<String, dynamic> payload,
  }) {
    if (planId == null) {
      return _repository.createMedication(payload);
    }
    return _repository.updateMedication(planId: planId, payload: payload);
  }

  Future<List<PendingMedicationModel>> getPendingToday({DateTime? date}) =>
      _repository.getPendingToday(date: date);

  Future<MedicationConsumptionModel> registerConsumption({
    required String medicationPlanId,
    String? scheduledTime,
    required String status,
    String? observations,
  }) =>
      _repository.registerConsumption(
        medicationPlanId: medicationPlanId,
        scheduledTime: scheduledTime,
        consumedAt: DateTime.now(),
        status: status,
        observations: observations,
      );

  Future<List<MedicationConsumptionModel>> getRecentConsumptions({
    int days = 7,
  }) {
    final DateTime now = DateTime.now();
    final DateTime from = now.subtract(Duration(days: days));
    return _repository.getConsumptions(from: from, to: now);
  }
}
