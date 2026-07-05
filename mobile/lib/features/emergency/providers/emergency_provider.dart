import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/emergency_controller.dart';
import '../datasource/emergency_remote_datasource.dart';
import '../repositories/emergency_repository.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';

final emergencyRemoteProvider = Provider<EmergencyRemoteDataSource>(
  (Ref ref) => EmergencyRemoteDataSource(),
);

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (Ref ref) => EmergencyRepository(ref.watch(emergencyRemoteProvider)),
);

final locationServiceProvider = Provider<LocationService>(
  (Ref ref) => LocationService(),
);

final emergencyServiceProvider = Provider<EmergencyService>(
  (Ref ref) => EmergencyService(
    ref.watch(emergencyRepositoryProvider),
    ref.watch(locationServiceProvider),
  ),
);

final emergencyControllerProvider =
    StateNotifierProvider<EmergencyController, EmergencyFlowState>(
  (Ref ref) => EmergencyController(ref.watch(emergencyServiceProvider)),
);
