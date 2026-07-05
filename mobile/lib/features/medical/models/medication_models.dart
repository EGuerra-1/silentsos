/// Horario de toma asociado a una version de medicamento.
class MedicationScheduleModel {
  const MedicationScheduleModel({
    this.id,
    required this.timeOfDay,
    this.notes,
  });

  final String? id;
  final String timeOfDay;
  final String? notes;

  factory MedicationScheduleModel.fromJson(Map<String, dynamic> json) {
    return MedicationScheduleModel(
      id: json['id'] as String?,
      timeOfDay: json['time_of_day']?.toString() ?? '',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toRequestJson() => <String, dynamic>{
        'time_of_day': _normalizeTime(timeOfDay),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };

  static String _normalizeTime(String value) {
    final List<String> parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return value;
  }
}

/// Version historica de un plan de medicamento.
class MedicationVersionModel {
  const MedicationVersionModel({
    this.id,
    required this.version,
    required this.name,
    required this.dose,
    required this.unit,
    required this.frequency,
    this.observations,
    this.validFrom,
    this.validTo,
    this.isCurrent = false,
    this.schedules = const <MedicationScheduleModel>[],
  });

  final String? id;
  final int version;
  final String name;
  final String dose;
  final String unit;
  final String frequency;
  final String? observations;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool isCurrent;
  final List<MedicationScheduleModel> schedules;

  factory MedicationVersionModel.fromJson(Map<String, dynamic> json) {
    return MedicationVersionModel(
      id: json['id'] as String?,
      version: json['version'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      observations: json['observations'] as String?,
      validFrom: DateTime.tryParse(json['valid_from']?.toString() ?? ''),
      validTo: DateTime.tryParse(json['valid_to']?.toString() ?? ''),
      isCurrent: json['is_current'] as bool? ?? false,
      schedules: (json['schedules'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(MedicationScheduleModel.fromJson)
          .toList(),
    );
  }
}

/// Plan de medicamento del usuario con versiones y horarios.
class MedicationPlanModel {
  const MedicationPlanModel({
    required this.id,
    required this.userId,
    this.title,
    required this.name,
    required this.dose,
    required this.unit,
    required this.frequency,
    this.observations,
    required this.currentVersion,
    this.createdAt,
    this.versions = const <MedicationVersionModel>[],
  });

  final String id;
  final String userId;
  final String? title;
  final String name;
  final String dose;
  final String unit;
  final String frequency;
  final String? observations;
  final int currentVersion;
  final DateTime? createdAt;
  final List<MedicationVersionModel> versions;

  String get doseLabel => dose.isEmpty ? unit : '$dose $unit'.trim();

  /// La API guarda name/dose/unit en la version activa, no en el plan raiz.
  MedicationVersionModel? get activeVersion {
    if (versions.isEmpty) return null;

    for (final MedicationVersionModel version in versions) {
      if (version.isCurrent) return version;
    }

    return versions.reduce(
      (MedicationVersionModel current, MedicationVersionModel next) =>
          next.version > current.version ? next : current,
    );
  }

  List<MedicationScheduleModel> get activeSchedules =>
      activeVersion?.schedules ?? const <MedicationScheduleModel>[];

  factory MedicationPlanModel.fromJson(Map<String, dynamic> json) {
    final List<MedicationVersionModel> parsedVersions =
        (json['versions'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(MedicationVersionModel.fromJson)
            .toList();

    final MedicationVersionModel? active = _resolveActiveVersion(
      parsedVersions,
      json['current_version'] as int?,
    );

    return MedicationPlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String?,
      name: active?.name ?? json['name'] as String? ?? '',
      dose: active?.dose ?? json['dose'] as String? ?? '',
      unit: active?.unit ?? json['unit'] as String? ?? '',
      frequency: active?.frequency ?? json['frequency'] as String? ?? '',
      observations: active?.observations ?? json['observations'] as String?,
      currentVersion: active?.version ?? json['current_version'] as int? ?? 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      versions: parsedVersions,
    );
  }

  static MedicationVersionModel? _resolveActiveVersion(
    List<MedicationVersionModel> versions,
    int? currentVersion,
  ) {
    if (versions.isEmpty) return null;

    for (final MedicationVersionModel version in versions) {
      if (version.isCurrent) return version;
    }

    if (currentVersion != null) {
      for (final MedicationVersionModel version in versions) {
        if (version.version == currentVersion) return version;
      }
    }

    return versions.reduce(
      (MedicationVersionModel current, MedicationVersionModel next) =>
          next.version > current.version ? next : current,
    );
  }
}

/// Medicamento pendiente de tomar hoy.
class PendingMedicationModel {
  const PendingMedicationModel({
    required this.medicationPlanId,
    required this.medicationName,
    required this.dose,
    this.unit,
    required this.scheduledTime,
    this.notes,
    required this.status,
  });

  final String medicationPlanId;
  final String medicationName;
  final String dose;
  final String? unit;
  final String scheduledTime;
  final String? notes;
  final String status;

  String get doseLabel {
    if (dose.contains(' ') || unit == null || unit!.isEmpty) return dose;
    return '$dose $unit';
  }

  factory PendingMedicationModel.fromJson(Map<String, dynamic> json) {
    final String doseValue = json['dose']?.toString() ?? '';
    final String? unitValue = json['unit']?.toString();

    return PendingMedicationModel(
      medicationPlanId: json['medication_plan_id']?.toString() ?? '',
      medicationName: json['medication_name']?.toString() ?? 'Medicamento',
      dose: doseValue,
      unit: unitValue,
      scheduledTime: json['scheduled_time']?.toString() ?? '',
      notes: json['schedule_notes'] as String? ?? json['notes'] as String?,
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

/// Registro de consumo de medicamento.
class MedicationConsumptionModel {
  const MedicationConsumptionModel({
    required this.id,
    required this.medicationPlanId,
    this.scheduledTime,
    this.consumedAt,
    required this.status,
    this.observations,
    this.medicationName,
    this.dose,
    this.unit,
  });

  final String id;
  final String medicationPlanId;
  final String? scheduledTime;
  final DateTime? consumedAt;
  final String status;
  final String? observations;
  final String? medicationName;
  final String? dose;
  final String? unit;

  String get doseLabel {
    if (dose == null) return '';
    if (unit == null || unit!.isEmpty) return dose!;
    return '$dose $unit';
  }

  factory MedicationConsumptionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? version =
        json['version'] as Map<String, dynamic>?;
    final Map<String, dynamic>? legacyPlan =
        json['medication_plan'] as Map<String, dynamic>?;

    return MedicationConsumptionModel(
      id: json['id']?.toString() ?? '',
      medicationPlanId: json['medication_plan_id']?.toString() ?? '',
      scheduledTime: json['scheduled_time']?.toString(),
      consumedAt: DateTime.tryParse(json['consumed_at']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      observations: json['observations']?.toString(),
      medicationName:
          version?['name']?.toString() ?? legacyPlan?['name']?.toString(),
      dose: version?['dose']?.toString() ?? legacyPlan?['dose']?.toString(),
      unit: version?['unit']?.toString() ?? legacyPlan?['unit']?.toString(),
    );
  }
}

/// Respuesta agrupada de pendientes del dia.
class PendingTodayResponse {
  const PendingTodayResponse({
    required this.date,
    required this.totalPending,
    required this.pending,
  });

  final String date;
  final int totalPending;
  final List<PendingMedicationModel> pending;

  factory PendingTodayResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPending =
        json['pending'] as List<dynamic>? ?? <dynamic>[];

    return PendingTodayResponse(
      date: json['date']?.toString() ?? '',
      totalPending: json['total_pending'] as int? ?? rawPending.length,
      pending: rawPending
          .whereType<Map<String, dynamic>>()
          .map(PendingMedicationModel.fromJson)
          .toList(),
    );
  }
}
