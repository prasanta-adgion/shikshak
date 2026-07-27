import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../providers_di/auth_providers.dart';
import '../state/auth_state.dart';

/// Owns the authenticated session. Login and registration each have their
/// own focused notifier for form state.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> checkAuthStatus() async {
    final (role, _) = await (
      ref.read(checkAuthStatusUseCaseProvider).call(),
      Future<void>.delayed(AppConstants.splashMinDuration),
    ).wait;

    state = role == null
        ? state.copyWith(status: AuthStatus.unauthenticated)
        : state.copyWith(status: AuthStatus.authenticated, role: role);
  }

  /// Called by [LoginNotifier] once the credentials are accepted.
  void setSession(UserEntity user) => state = AuthState(
    status: AuthStatus.authenticated,
    user: user,
    role: user.role,
  );

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
