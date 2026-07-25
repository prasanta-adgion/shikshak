import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/login_usecase.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';

/// Owns authenticated-session state. Registration has a focused notifier.
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
