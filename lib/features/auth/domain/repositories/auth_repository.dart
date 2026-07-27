import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../params/auth_params.dart';

abstract interface class AuthRepository {
  Future<ApiResult<UserEntity>> login(LoginParams params);

  Future<ApiResult<void>> register(RegisterParams params);

  /// Completes signup. On success the session is persisted, exactly as after
  /// [login], and the verified user is returned.
  Future<ApiResult<UserEntity>> verifySignupOtp(VerifySignupOtpParams params);

  /// Sends a fresh signup code to the same recipient.
  Future<ApiResult<void>> resendSignupOtp(ResendOtpParams params);

  /// Role of the stored session, or `null` when there is no valid session.
  Future<UserRole?> sessionRole();

  Future<void> logout();
}
