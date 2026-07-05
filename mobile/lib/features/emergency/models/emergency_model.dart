/// Tipos de emergencia soportados por POST /emergencies/urgency.
enum EmergencyType {
  medical('medical'),
  general('general');

  const EmergencyType(this.apiValue);

  final String apiValue;
}

/// Estados del pipeline en backend.
enum EmergencyStatus {
  pending('PENDING'),
  analyzing('ANALYZING'),
  triageGenerated('TRIAGE_GENERATED'),
  audioGenerated('AUDIO_GENERATED'),
  callStarted('CALL_STARTED'),
  smsSent('SMS_SENT'),
  completed('COMPLETED'),
  failed('FAILED');

  const EmergencyStatus(this.apiValue);

  final String apiValue;

  static EmergencyStatus? fromApi(String? raw) {
    if (raw == null) return null;
    for (final EmergencyStatus status in EmergencyStatus.values) {
      if (status.apiValue == raw) return status;
    }
    return null;
  }

  bool get isTerminal =>
      this == EmergencyStatus.completed || this == EmergencyStatus.failed;
}

/// Modelo de emergencia devuelto por la API.
class EmergencyModel {
  const EmergencyModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.address,
    this.displayStatus,
    this.callMode,
    this.priority,
  });

  final String id;
  final String userId;
  final EmergencyType type;
  final EmergencyStatus status;
  final double latitude;
  final double longitude;
  final String? address;
  final String? displayStatus;
  final String? callMode;
  final String? priority;

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    final String typeRaw = json['type']?.toString() ?? 'general';
    final EmergencyType type = EmergencyType.values.firstWhere(
      (EmergencyType item) => item.apiValue == typeRaw,
      orElse: () => EmergencyType.general,
    );

    return EmergencyModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: type,
      status: EmergencyStatus.fromApi(json['status']?.toString()) ??
          EmergencyStatus.pending,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      address: json['address']?.toString(),
      displayStatus: json['display_status']?.toString(),
      callMode: json['call_mode']?.toString(),
      priority: json['priority']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

/// Coordenadas + direccion legible para el payload de urgencia.
class EmergencyLocation {
  const EmergencyLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracyMeters;
}

/// Imagenes capturadas para POST /emergencies/contextual.
class ContextualEmergencyPayload {
  const ContextualEmergencyPayload({
    required this.frontImagePath,
    required this.backImagePath,
    this.contextText,
  });

  final String frontImagePath;
  final String backImagePath;
  final String? contextText;
}
