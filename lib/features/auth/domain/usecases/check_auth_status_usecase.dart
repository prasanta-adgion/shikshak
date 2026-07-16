import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

/// Splash-time session restore.
///
/// Returns `null` when no session is persisted (user must log in);
/// otherwise returns the role persisted with that session. Does not hit the
/// network — login/register/logout are the only calls that talk to the API.
class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserRole?> call() async {
    final hasSession = await _repository.hasValidSession();
    if (!hasSession) return null;
    return _repository.getPersistedRole();
  }
}
