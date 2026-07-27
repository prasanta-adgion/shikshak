import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// `data` payload of every endpoint that opens a session — login and
/// signup OTP verification both reply with the same shape.
class AuthSessionModel {
  const AuthSessionModel({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  final String token;
  final String refreshToken;
  final AuthUserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String,
        user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );

  UserEntity toEntity() => UserEntity(
    id: id,
    fullName: name,
    email: email,
    role: UserRole.tryParse(role) ?? UserRole.student,
    avatarUrl: avatarUrl,
  );
}
