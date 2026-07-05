import '../models/emergency_model.dart';
import '../repositories/emergency_repository.dart';
import '../services/location_service.dart';

/// Orquesta ubicacion + llamadas al backend de emergencias.
class EmergencyService {
  const EmergencyService(this._repository, this._locationService);

  final EmergencyRepository _repository;
  final LocationService _locationService;

  Future<void> ensureLocationPermission() => _locationService.ensureReady();

  Future<EmergencyLocation> getCurrentLocation() =>
      _locationService.getCurrentLocation();

  Future<EmergencyModel> triggerUrgency({
    required EmergencyType type,
    required EmergencyLocation location,
  }) {
    final String? priority =
        type == EmergencyType.medical ? 'alta' : null;

    return _repository.createUrgency(
      type: type,
      location: location,
      priority: priority,
    );
  }

  Future<EmergencyModel> triggerContextual({
    required ContextualEmergencyPayload payload,
    required EmergencyLocation location,
  }) =>
      _repository.createContextual(payload: payload, location: location);

  Future<EmergencyModel> pollStatus(String emergencyId) =>
      _repository.getById(emergencyId);
}
