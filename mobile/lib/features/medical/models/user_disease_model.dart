/// Resumen embebido del catalogo en listados de enfermedades del usuario.
class DiseaseCatalogSummary {
  const DiseaseCatalogSummary({
    required this.name,
    required this.classification,
  });

  final String name;
  final String classification;

  factory DiseaseCatalogSummary.fromJson(Map<String, dynamic> json) {
    return DiseaseCatalogSummary(
      name: json['name'] as String? ?? '',
      classification: json['classification'] as String? ?? '',
    );
  }
}

/// Enfermedad registrada del usuario autenticado.
class UserDiseaseModel {
  const UserDiseaseModel({
    required this.id,
    required this.userId,
    required this.diseaseCatalogId,
    this.notes,
    this.diagnosedAt,
    this.diseaseCatalog,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String diseaseCatalogId;
  final String? notes;
  final DateTime? diagnosedAt;
  final DiseaseCatalogSummary? diseaseCatalog;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName =>
      diseaseCatalog?.name.isNotEmpty == true ? diseaseCatalog!.name : 'Enfermedad';

  String get displayClassification => diseaseCatalog?.classification ?? '';

  factory UserDiseaseModel.fromJson(Map<String, dynamic> json) {
    return UserDiseaseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      diseaseCatalogId: json['disease_catalog_id'] as String,
      notes: json['notes'] as String?,
      diagnosedAt: _parseDate(json['diagnosed_at']),
      diseaseCatalog: json['disease_catalog'] is Map<String, dynamic>
          ? DiseaseCatalogSummary.fromJson(
              json['disease_catalog'] as Map<String, dynamic>,
            )
          : null,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
