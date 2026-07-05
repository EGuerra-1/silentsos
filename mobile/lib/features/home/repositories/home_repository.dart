import '../datasource/home_datasource.dart';
import '../models/home_alert_model.dart';

class HomeRepository {
  HomeRepository(this._dataSource);

  final HomeDataSource _dataSource;

  Future<List<HomeAlertModel>> fetchAlerts() => _dataSource.fetchAlerts();
}
