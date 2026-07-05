import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_logger.dart';
import '../models/disease_catalog_model.dart';
import '../models/medication_models.dart';
import '../models/user_disease_model.dart';
import '../services/medical_service.dart';

/// Base con proteccion contra actualizaciones tras dispose.
abstract class SafeMedicalController<T> extends StateNotifier<AsyncValue<T>> {
  SafeMedicalController(super.initialState);

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @protected
  bool get isDisposed => _disposed;

  @protected
  void setStateSafe(AsyncValue<T> value) {
    if (_disposed) return;
    state = value;
  }
}

/// Lista de enfermedades del usuario autenticado.
class DiseasesController extends SafeMedicalController<List<UserDiseaseModel>> {
  DiseasesController(this._service) : super(const AsyncValue.loading());

  final MedicalService _service;

  Future<void> load() async {
    setStateSafe(const AsyncValue.loading());
    final AsyncValue<List<UserDiseaseModel>> result =
        await AsyncValue.guard<List<UserDiseaseModel>>(
      () => _service.getUserDiseases(),
    );
    setStateSafe(result);
  }
}

/// Catalogo global de enfermedades.
class DiseaseCatalogController
    extends SafeMedicalController<List<DiseaseCatalogModel>> {
  DiseaseCatalogController(this._service) : super(const AsyncValue.loading());

  final MedicalService _service;

  Future<void> load() async {
    setStateSafe(const AsyncValue.loading());
    final AsyncValue<List<DiseaseCatalogModel>> result =
        await AsyncValue.guard<List<DiseaseCatalogModel>>(
      () => _service.getDiseaseCatalog(),
    );
    setStateSafe(result);
  }
}

/// Planes de medicamento del usuario.
class MedicationsController
    extends SafeMedicalController<List<MedicationPlanModel>> {
  MedicationsController(this._service) : super(const AsyncValue.loading());

  final MedicalService _service;

  Future<void> load() async {
    setStateSafe(const AsyncValue.loading());
    final AsyncValue<List<MedicationPlanModel>> result =
        await AsyncValue.guard<List<MedicationPlanModel>>(
      () => _service.getMedications(),
    );
    setStateSafe(result);
  }
}

/// Dosis pendientes del dia + historial reciente de consumos.
class MedicalDayController extends SafeMedicalController<MedicalDayState> {
  MedicalDayController(this._service) : super(const AsyncValue.loading());

  final MedicalService _service;

  Future<void> load() async {
    setStateSafe(const AsyncValue.loading());

    try {
      final List<PendingMedicationModel> pending =
          await _service.getPendingToday();

      List<MedicationConsumptionModel> recent =
          const <MedicationConsumptionModel>[];
      try {
        recent = await _service.getRecentConsumptions();
      } catch (error, stackTrace) {
        AppLogger.warning(
          '[Medical] historial de consumos no disponible',
        );
        AppLogger.error(
          '[Medical] getRecentConsumptions fallo',
          error: error,
          stackTrace: stackTrace,
        );
      }

      setStateSafe(
        AsyncValue.data(
          MedicalDayState(pending: pending, recentConsumptions: recent),
        ),
      );
    } catch (error, stackTrace) {
      setStateSafe(AsyncValue.error(error, stackTrace));
    }
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
