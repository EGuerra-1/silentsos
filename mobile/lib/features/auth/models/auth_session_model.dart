import '../entities/auth_user.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUser user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: (json['token'] ?? '').toString(),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
