import '../entities/home_alert_entity.dart';
import '../repositories/home_repository.dart';

class HomeService {
  HomeService(this._repository);

  final HomeRepository _repository;

  Future<List<HomeAlertEntity>> getAlerts() async {
    return _repository.fetchAlerts();
  }
}
