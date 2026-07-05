import '../datasource/medical_remote_datasource.dart';
import '../models/disease_catalog_model.dart';
import '../models/medication_models.dart';
import '../models/user_disease_model.dart';

/// Capa de acceso a datos del modulo medico.
class MedicalRepository {
  MedicalRepository(this._remote);

  final MedicalRemoteDataSource _remote;

  Future<List<DiseaseCatalogModel>> getDiseaseCatalog() =>
      _remote.fetchDiseaseCatalog();

  Future<List<UserDiseaseModel>> getUserDiseases() => _remote.fetchUserDiseases();

  Future<UserDiseaseModel> createUserDisease({
    required String diseaseCatalogId,
    String? notes,
    DateTime? diagnosedAt,
  }) =>
      _remote.createUserDisease(
        diseaseCatalogId: diseaseCatalogId,
        notes: notes,
        diagnosedAt: diagnosedAt,
      );

  Future<UserDiseaseModel> updateUserDisease({
    required String id,
    required String diseaseCatalogId,
    String? notes,
    DateTime? diagnosedAt,
  }) =>
      _remote.updateUserDisease(
        id: id,
        diseaseCatalogId: diseaseCatalogId,
        notes: notes,
        diagnosedAt: diagnosedAt,
      );

  Future<List<MedicationPlanModel>> getMedications() => _remote.fetchMedications();

  Future<MedicationPlanModel> createMedication(Map<String, dynamic> payload) =>
      _remote.createMedication(payload);

  Future<MedicationPlanModel> updateMedication({
    required String planId,
    required Map<String, dynamic> payload,
  }) =>
      _remote.updateMedication(planId: planId, payload: payload);

  Future<List<PendingMedicationModel>> getPendingToday({DateTime? date}) =>
      _remote.fetchPendingToday(date: date);

  Future<MedicationConsumptionModel> registerConsumption({
    required String medicationPlanId,
    String? scheduledTime,
    DateTime? consumedAt,
    String? status,
    String? observations,
  }) =>
      _remote.registerConsumption(
        medicationPlanId: medicationPlanId,
        scheduledTime: scheduledTime,
        consumedAt: consumedAt,
        status: status,
        observations: observations,
      );

  Future<List<MedicationConsumptionModel>> getConsumptions({
    DateTime? from,
    DateTime? to,
    String? status,
  }) =>
      _remote.fetchConsumptions(from: from, to: to, status: status);
}
