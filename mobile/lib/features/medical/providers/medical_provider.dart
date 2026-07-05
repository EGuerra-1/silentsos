import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/disease_catalog_model.dart';
import '../models/medication_models.dart';
import '../models/user_disease_model.dart';
import '../controllers/medical_controllers.dart';
import '../datasource/medical_remote_datasource.dart';
import '../repositories/medical_repository.dart';
import '../services/medical_service.dart';

/// Cadena DI del modulo medico: datasource -> repository -> service -> controllers.
final medicalRemoteProvider = Provider<MedicalRemoteDataSource>(
  (Ref ref) => MedicalRemoteDataSource(),
);

final medicalRepositoryProvider = Provider<MedicalRepository>(
  (Ref ref) => MedicalRepository(ref.watch(medicalRemoteProvider)),
);

final medicalServiceProvider = Provider<MedicalService>(
  (Ref ref) => MedicalService(ref.watch(medicalRepositoryProvider)),
);

final diseasesControllerProvider =
    StateNotifierProvider<DiseasesController, AsyncValue<List<UserDiseaseModel>>>(
  (Ref ref) => DiseasesController(ref.watch(medicalServiceProvider)),
);

final diseaseCatalogControllerProvider = StateNotifierProvider<
    DiseaseCatalogController, AsyncValue<List<DiseaseCatalogModel>>>(
  (Ref ref) => DiseaseCatalogController(ref.watch(medicalServiceProvider)),
);

final medicationsControllerProvider = StateNotifierProvider<
    MedicationsController, AsyncValue<List<MedicationPlanModel>>>(
  (Ref ref) => MedicationsController(ref.watch(medicalServiceProvider)),
);

final medicalDayControllerProvider =
    StateNotifierProvider<MedicalDayController, AsyncValue<MedicalDayState>>(
  (Ref ref) => MedicalDayController(ref.watch(medicalServiceProvider)),
);
