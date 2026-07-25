import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/register_usecase.dart';
import '../providers/auth_providers.dart';

/// Owns only the loading, success, and failure state of registration.
class RegisterNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> register(RegisterParams params) async {
    state = const AsyncLoading();
    final result = await ref.read(registerUseCaseProvider).call(params);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData(null);
        return true;
      },
      onFailure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return false;
      },
    );
  }
}
