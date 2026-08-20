import '../../../../core/network/api_result.dart';
import '../repositories/forgot_password_repository.dart';

/// Input for [ResetPasswordUseCase].
class ResetPasswordParams {
  const ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;
}

/// Step 2 of the reset flow: the OTP and the new password travel together, so
/// the backend verifies and updates in one call — there is no reset ticket to
/// carry between screens.
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final ForgotPasswordRepository _repository;

  Future<ApiResult<void>> call(ResetPasswordParams params) =>
      _repository.resetPasswordWithVerifyOTP(params);
}
