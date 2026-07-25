import '../../../../core/network/api_result.dart';
import '../entities/password_reset_ticket.dart';
import '../usecases/request_reset_otp_usecase.dart';
import '../usecases/reset_password_usecase.dart';
import '../usecases/verify_reset_otp_usecase.dart';

/// The presentation layer only ever sees this abstraction; the concrete
/// implementation (remote API) lives in the data layer.
///
/// Password reset persists no session, so — unlike `AuthRepository` — nothing
/// here touches secure storage.
abstract interface class ForgotPasswordRepository {
  /// Asks the backend to send a reset OTP to the given email.
  Future<ApiResult<void>> requestResetOtp(RequestResetOtpParams params);

  /// Exchanges a valid OTP for a [PasswordResetTicket].
  Future<ApiResult<PasswordResetTicket>> verifyResetOtp(
    VerifyResetOtpParams params,
  );

  /// Sets the new password, completing the flow.
  Future<ApiResult<void>> resetPassword(ResetPasswordParams params);
}
