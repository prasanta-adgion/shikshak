import 'user_role.dart';

class UserEntity {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  /// First name, for friendly greetings.
  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return fullName;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
