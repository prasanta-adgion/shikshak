import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserEntity>> call(LoginParams params) =>
      _repository.login(params);
}

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<void>> call(RegisterParams params) =>
      _repository.register(params);
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  const CheckAuthStatusUseCase(this._repository);

  Future<UserRole?> call() => _repository.sessionRole();
}
