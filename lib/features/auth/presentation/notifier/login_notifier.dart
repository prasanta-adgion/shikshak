import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/params/auth_params.dart';
import '../providers_di/auth_providers.dart';

class LoginNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the signed-in user, or `null` when login failed.
  Future<UserEntity?> login(LoginParams params) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider).call(params);

    return result.fold(
      onSuccess: (user) {
        state = const AsyncData(null);
        ref.read(authStateNotifierProvider.notifier).setSession(user);
        return user;
      },
      onFailure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return null;
      },
    );
  }
}
