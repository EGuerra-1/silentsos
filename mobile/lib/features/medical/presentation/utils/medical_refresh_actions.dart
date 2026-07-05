import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medical_provider.dart';

/// Acciones compartidas de refresco del modulo medico.
abstract final class MedicalRefreshActions {
  static Future<void> reloadMedications(WidgetRef ref) async {
    await Future.wait(<Future<void>>[
      ref.read(medicationsControllerProvider.notifier).load(),
      ref.read(medicalDayControllerProvider.notifier).load(),
    ]);
  }

  static Future<void> reloadDiseases(WidgetRef ref) async {
    await ref.read(diseasesControllerProvider.notifier).load();
  }
}
