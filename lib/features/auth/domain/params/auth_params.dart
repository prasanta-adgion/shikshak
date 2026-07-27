import '../entities/user_role.dart';

// contains input received from the UI
class LoginParams {
  /// Email address or mobile number.
  final String identifier;
  final String password;

  const LoginParams({required this.identifier, required this.password});
}

class RegisterParams {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final UserRole role;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
  });
}
