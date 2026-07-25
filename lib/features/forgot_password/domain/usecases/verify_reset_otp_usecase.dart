import '../../../../core/network/api_result.dart';
import '../entities/password_reset_ticket.dart';
import '../repositories/forgot_password_repository.dart';

/// Input for [VerifyResetOtpUseCase].
class VerifyResetOtpParams {
  const VerifyResetOtpParams({required this.email, required this.otp});

  final String email;
  final String otp;
}

/// Step 2 of the reset flow: prove ownership of the email by returning the
/// code, receiving a [PasswordResetTicket] in exchange.
class VerifyResetOtpUseCase {
  const VerifyResetOtpUseCase(this._repository);

  final ForgotPasswordRepository _repository;

  Future<ApiResult<PasswordResetTicket>> call(VerifyResetOtpParams params) =>
      _repository.verifyResetOtp(params);
}
