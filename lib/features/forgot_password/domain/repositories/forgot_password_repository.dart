import '../../../../core/network/api_result.dart';
import '../usecases/request_reset_otp_usecase.dart';
import '../usecases/reset_password_usecase.dart';

abstract interface class ForgotPasswordRepository {
  /// Step 1 — emails a one-time code.
  Future<ApiResult<void>> requestResetOtp(RequestResetOtpParams params);

  /// Step 2 — verifies the code and stores the new password.
  Future<ApiResult<void>> resetPasswordWithVerifyOTP(
    ResetPasswordParams params,
  );
}
