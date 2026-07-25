import 'user_role.dart';

/// Domain representation of an authenticated user.
///
/// Deliberately framework-free (no json, no Flutter imports) — mapping from
/// transport models happens in the data layer.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final UserRole role;

  /// First name, for friendly greetings.
  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return fullName;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
