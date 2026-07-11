import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

/// Input for [LoginUseCase].
class LoginParams {
  const LoginParams({
    required this.identifier,
    required this.password,
    required this.role,
    this.rememberMe = true,
  });

  /// Email address or mobile number.
  final String identifier;
  final String password;
  final UserRole role;
  final bool rememberMe;
}

/// Authenticates a user with email/mobile + password.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserEntity>> call(LoginParams params) =>
      _repository.login(params);
}
