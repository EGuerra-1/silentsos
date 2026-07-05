import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/disease_catalog_model.dart';
import '../models/medication_models.dart';
import '../models/user_disease_model.dart';
import '../services/medical_service.dart';

/// Lista de enfermedades del usuario autenticado.
class DiseasesController extends StateNotifier<AsyncValue<List<UserDiseaseModel>>> {
  DiseasesController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final MedicalService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<List<UserDiseaseModel>>(
      () => _service.getUserDiseases(),
    );
  }
}

/// Catalogo global de enfermedades (cache en memoria mientras viva el provider).
class DiseaseCatalogController
    extends StateNotifier<AsyncValue<List<DiseaseCatalogModel>>> {
  DiseaseCatalogController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final MedicalService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<List<DiseaseCatalogModel>>(
      () => _service.getDiseaseCatalog(),
    );
  }
}

/// Planes de medicamento del usuario.
class MedicationsController
    extends StateNotifier<AsyncValue<List<MedicationPlanModel>>> {
  MedicationsController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final MedicalService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<List<MedicationPlanModel>>(
      () => _service.getMedications(),
    );
  }
}

/// Dosis pendientes del dia + historial reciente de consumos.
class MedicalDayController extends StateNotifier<AsyncValue<MedicalDayState>> {
  MedicalDayController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final MedicalService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<MedicalDayState>(() async {
      final List<PendingMedicationModel> pending =
          await _service.getPendingToday();
      final List<MedicationConsumptionModel> recent =
          await _service.getRecentConsumptions();
      return MedicalDayState(pending: pending, recentConsumptions: recent);
    });
  }

  Future<void> markConsumption({
    required PendingMedicationModel item,
    required String status,
  }) async {
    await _service.registerConsumption(
      medicationPlanId: item.medicationPlanId,
      scheduledTime: item.scheduledTime,
      status: status,
    );
    await load();
  }
}

/// Estado agregado del tab de medicamentos (pendientes + actividad).
class MedicalDayState {
  const MedicalDayState({
    required this.pending,
    required this.recentConsumptions,
  });

  final List<PendingMedicationModel> pending;
  final List<MedicationConsumptionModel> recentConsumptions;
}
