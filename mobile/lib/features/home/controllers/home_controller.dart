import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/home_alert_entity.dart';
import '../services/home_service.dart';

/// Controla la carga del dashboard principal y expone estado AsyncValue.
class HomeController extends StateNotifier<AsyncValue<List<HomeAlertEntity>>> {
  HomeController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final HomeService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<List<HomeAlertEntity>>(
      () => _service.getAlerts(),
    );
  }
}
