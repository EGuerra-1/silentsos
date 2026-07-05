import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/home_controller.dart';
import '../datasource/home_datasource.dart';
import '../entities/home_alert_entity.dart';
import '../repositories/home_repository.dart';
import '../services/home_service.dart';

/// Cadena DI de Home: datasource -> repository -> service -> controller.
final homeDatasourceProvider = Provider<HomeDataSource>(
  (Ref ref) => HomeDataSource(),
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (Ref ref) => HomeRepository(ref.watch(homeDatasourceProvider)),
);

final homeServiceProvider = Provider<HomeService>(
  (Ref ref) => HomeService(ref.watch(homeRepositoryProvider)),
);

final homeControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<List<HomeAlertEntity>>>(
  (Ref ref) => HomeController(ref.watch(homeServiceProvider)),
);
