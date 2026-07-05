/// Entrada del catalogo global de enfermedades (`GET /medical/disease_catalogs`).
class DiseaseCatalogModel {
  const DiseaseCatalogModel({
    required this.id,
    required this.name,
    required this.classification,
    this.description,
  });

  final String id;
  final String name;
  final String classification;
  final String? description;

  factory DiseaseCatalogModel.fromJson(Map<String, dynamic> json) {
    return DiseaseCatalogModel(
      id: json['id'] as String,
      name: json['name'] as String,
      classification: json['classification'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}
