import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

part 'auth_state.freezed.dart';

/// Session lifecycle.
enum AuthStatus {
  /// Splash is restoring a persisted session.
  checking,

  /// A valid session exists; [AuthState.user] is non-null.
  authenticated,

  /// No session — user is somewhere in the auth flow.
  unauthenticated,
}

/// Immutable state for the whole authentication feature.
@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.checking) AuthStatus status,

    /// True while a login/register request is in flight.
    @Default(false) bool isSubmitting,

    /// The authenticated user (null until [status] is authenticated).
    UserEntity? user,

    /// Role picked on the role-selection screen; carried through the
    /// login/registration flow.
    UserRole? selectedRole,

    /// Last auth error, surfaced by the UI as a snackbar. Cleared on the
    /// next submission.
    String? errorMessage,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}
