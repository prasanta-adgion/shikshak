import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/params/auth_params.dart';
import '../providers_di/auth_providers.dart';

/// Owns only the loading, success, and failure state of signup OTP entry.
/// Verification opens a session, so the user is handed to [AuthNotifier],
/// which owns it — same contract as [LoginNotifier].
class SignupOtpNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the verified user, or `null` when verification failed.
  Future<UserEntity?> verify(VerifySignupOtpParams params) async {
    state = const AsyncLoading();
    final result = await ref.read(verifySignupOtpUseCaseProvider).call(params);

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

  /// Sends a fresh code to the same recipient. Shares this notifier's state
  /// with [verify], so the two can never run at once.
  Future<bool> resend(ResendOtpParams params) async {
    state = const AsyncLoading();
    final result = await ref.read(resendSignupOtpUseCaseProvider).call(params);

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
