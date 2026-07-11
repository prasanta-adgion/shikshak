import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Splash-time session restore.
///
/// Returns `null` when no session is persisted (user must log in);
/// otherwise fetches the profile for the stored token.
class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserEntity>?> call() async {
    final hasSession = await _repository.hasValidSession();
    if (!hasSession) return null;
    return _repository.fetchProfile();
  }
}
