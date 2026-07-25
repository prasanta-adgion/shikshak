import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> checkAuthStatus() async {
    final (role, _) = await (
      ref.read(checkAuthStatusUseCaseProvider).call(),
      Future<void>.delayed(AppConstants.splashMinDuration),
    ).wait;

    if (role == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      selectedRole: role,
    );
  }

  Future<void> login({
    required String identifier,
    required String password,
    required UserRole role,
    bool rememberMe = true,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref
        .read(loginUseCaseProvider)
        .call(
          LoginParams(
            identifier: identifier,
            password: password,
            role: role,
            rememberMe: rememberMe,
          ),
        );

    result.fold(
      onSuccess: _setAuthenticated,
      onFailure: (exception) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      ),
    );
  }

  /// Submits the signup form. On success the backend has emailed a code — the
  /// user is NOT authenticated yet, so this sets [AuthState.pendingSignup]
  /// rather than a session. The register screen observes that and routes to
  /// OTP entry.
  Future<void> register(RegisterParams params) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      pendingSignup: null,
    );

    final result = await ref.read(registerUseCaseProvider).call(params);

    result.fold(
      onSuccess: (challenge) => state = state.copyWith(
        isSubmitting: false,
        pendingSignup: challenge,
      ),
      onFailure: (exception) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      ),
    );
  }

  /// Abandons an in-flight signup (user backed out of OTP entry).
  void clearPendingSignup() => state = state.copyWith(pendingSignup: null);

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _setAuthenticated(UserEntity user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      isSubmitting: false,
      user: user,
      errorMessage: null,
    );
  }
}
