import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../usecases/login_usecase.dart';
import '../usecases/register_usecase.dart';

/// The presentation layer only ever sees this abstraction; the concrete
/// implementation (remote API + secure storage) lives in the data layer.
abstract interface class AuthRepository {
  /// Authenticates the user and persists the session on success.
  Future<ApiResult<UserEntity>> login(LoginParams params);

  /// Creates an account and persists the session on success.
  Future<ApiResult<UserEntity>> register(RegisterParams params);

  /// Whether a persisted access token exists.
  Future<bool> hasValidSession();

  /// The role persisted with the last successful session, if any.
  Future<UserRole?> getPersistedRole();

  /// Clears the persisted session.
  Future<void> logout();
}
