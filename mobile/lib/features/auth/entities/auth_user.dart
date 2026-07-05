class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      role: (json['rol'] ?? '').toString(),
    );
  }
}
