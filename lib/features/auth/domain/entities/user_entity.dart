import 'user_role.dart';

class UserEntity {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.mobileNumber,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;

  /// Absent from the session endpoints — it is carried over from signup.
  final String? mobileNumber;

  final UserRole role;
  final String? avatarUrl;

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobileNumber,
    UserRole? role,
    String? avatarUrl,
  }) => UserEntity(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    role: role ?? this.role,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  /// First name, for friendly greetings.
  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return fullName;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
