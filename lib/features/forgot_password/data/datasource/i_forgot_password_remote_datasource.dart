import '../models/request_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';

/// Contract for the password-reset API — two calls, one per step.
abstract interface class ForgotPasswordRemoteDataSource {
  /// Step 1 — emails a one-time code.
  Future<void> requestResetOtp(RequestResetOtpRequestModel request);

  /// Step 2 — verifies the code and stores the new password.
  Future<void> resetPassword(ResetPasswordRequestModel request);
}
