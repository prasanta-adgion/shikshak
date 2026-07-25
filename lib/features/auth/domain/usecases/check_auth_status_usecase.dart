import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserRole?> call() async {
    final hasSession = await _repository.hasValidSession();
    if (!hasSession) return null;
    return _repository.getPersistedRole();
  }
}
