/// Perfil del usuario autenticado.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.cellphone,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String cellphone;
  final String role;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      cellphone: json['cellphone']?.toString() ?? '',
      role: json['rol']?.toString() ?? 'user',
    );
  }
}
