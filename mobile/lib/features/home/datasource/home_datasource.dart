import '../models/home_alert_model.dart';

class HomeDataSource {
  Future<List<HomeAlertModel>> fetchAlerts() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return const <HomeAlertModel>[
      HomeAlertModel(
        title: 'Monitoreo activo',
        subtitle: 'Tu ubicacion se comparte con tu contacto de confianza.',
        isActive: true,
      ),
      HomeAlertModel(
        title: 'Ultimo chequeo',
        subtitle: 'Hace 2 minutos',
        isActive: true,
      ),
    ];
  }
}
