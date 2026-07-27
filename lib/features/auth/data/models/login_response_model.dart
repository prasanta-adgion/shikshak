import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// `data` payload of the login endpoint.
class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  final String token;
  final String refreshToken;
  final LoginUserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String,
        user: LoginUserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class LoginUserModel {
  const LoginUserModel({
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

  factory LoginUserModel.fromJson(Map<String, dynamic> json) => LoginUserModel(
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
