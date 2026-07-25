import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../usecases/login_usecase.dart';

abstract interface class AuthRepository {
  Future<ApiResult<UserEntity>> login(LoginParams params);

  Future<ApiResult<void>> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required UserRole role,
  });

  Future<bool> hasValidSession();

  Future<UserRole?> getPersistedRole();

  Future<void> logout();
}
