import '../datasource/emergency_remote_datasource.dart';
import '../models/emergency_model.dart';

class EmergencyRepository {
  const EmergencyRepository(this._remote);

  final EmergencyRemoteDataSource _remote;

  Future<EmergencyModel> createUrgency({
    required EmergencyType type,
    required EmergencyLocation location,
    String? priority,
  }) =>
      _remote.createUrgency(
        type: type,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        priority: priority,
      );

  Future<EmergencyModel> createContextual({
    required ContextualEmergencyPayload payload,
    required EmergencyLocation location,
  }) =>
      _remote.createContextual(
        frontImagePath: payload.frontImagePath,
        backImagePath: payload.backImagePath,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        contextText: payload.contextText,
      );

  Future<EmergencyModel> getById(String id) => _remote.fetchById(id);
}
