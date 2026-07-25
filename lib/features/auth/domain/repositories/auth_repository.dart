import '../../../../core/network/api_result.dart';
import '../entities/signup_otp_challenge.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../usecases/login_usecase.dart';
import '../usecases/register_usecase.dart';

abstract interface class AuthRepository {
  Future<ApiResult<UserEntity>> login(LoginParams params);

  Future<ApiResult<SignupOtpChallenge>> register(RegisterParams params);

  Future<bool> hasValidSession();

  Future<UserRole?> getPersistedRole();

  Future<void> logout();
}
