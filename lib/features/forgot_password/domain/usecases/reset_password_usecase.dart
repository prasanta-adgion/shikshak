import '../../../../core/network/api_result.dart';
import '../repositories/forgot_password_repository.dart';

/// Input for [ResetPasswordUseCase].
class ResetPasswordParams {
  const ResetPasswordParams({
    required this.email,
    required this.newPassword,
    this.resetToken,
  });

  final String email;
  final String newPassword;

  /// Ticket issued by the verify-OTP step. Nullable because the backend may
  /// track the verified state server-side instead — see [PasswordResetTicket].
  final String? resetToken;
}

/// Step 3 of the reset flow: set the new password.
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final ForgotPasswordRepository _repository;

  Future<ApiResult<void>> call(ResetPasswordParams params) =>
      _repository.resetPassword(params);
}
