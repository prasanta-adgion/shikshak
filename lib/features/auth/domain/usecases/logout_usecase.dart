import '../repositories/auth_repository.dart';

/// Ends the current session and clears persisted credentials.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
