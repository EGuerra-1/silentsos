import '../../../core/constants/emergency_relationship_options.dart';

/// Contacto de emergencia del usuario autenticado.
class EmergencyContactModel {
  const EmergencyContactModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.cellphone,
    required this.relationship,
  });

  final String id;
  final String userId;
  final String fullName;
  final String cellphone;
  final String relationship;

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      cellphone: json['cellphone']?.toString() ?? '',
      relationship: EmergencyRelationshipOptions.normalize(
        json['relationship']?.toString() ?? '',
      ),
    );
  }
}
