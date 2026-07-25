import '../../../../core/network/api_result.dart';
import '../entities/signup_otp_challenge.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final UserRole role;
}

/// Starts signup for a new teacher or student, triggering the verification
/// email. The account only becomes usable once the OTP is verified.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<SignupOtpChallenge>> call(RegisterParams params) =>
      _repository.register(params);
}
