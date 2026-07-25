import '../../domain/entities/signup_otp_challenge.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

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
class AuthState {
  final AuthStatus status;

  /// True while a login/register request is in flight.
  final bool isSubmitting;

  /// The authenticated user (null until [status] is authenticated).
  final UserEntity? user;

  /// Role picked on the role-selection screen; carried through the
  /// login/registration flow.
  final UserRole? selectedRole;

  /// Last auth error, surfaced by the UI as a snackbar. Cleared on the
  /// next submission.
  final String? errorMessage;

  /// Set when signup has been submitted and the backend emailed a code.
  /// Non-null means "awaiting OTP verification" — the user is NOT yet
  /// authenticated. Cleared once verification completes or the flow restarts.
  final SignupOtpChallenge? pendingSignup;

  const AuthState({
    this.status = AuthStatus.checking,
    this.isSubmitting = false,
    this.user,
    this.selectedRole,
    this.errorMessage,
    this.pendingSignup,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  static const _unset = Object();

  /// Nullable fields default to a sentinel so callers can either keep the
  /// current value (omit the argument) or clear it (pass null explicitly).
  AuthState copyWith({
    AuthStatus? status,
    bool? isSubmitting,
    Object? user = _unset,
    Object? selectedRole = _unset,
    Object? errorMessage = _unset,
    Object? pendingSignup = _unset,
  }) => AuthState(
    status: status ?? this.status,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    user: identical(user, _unset) ? this.user : user as UserEntity?,
    selectedRole: identical(selectedRole, _unset)
        ? this.selectedRole
        : selectedRole as UserRole?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    pendingSignup: identical(pendingSignup, _unset)
        ? this.pendingSignup
        : pendingSignup as SignupOtpChallenge?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          other.status == status &&
          other.isSubmitting == isSubmitting &&
          other.user == user &&
          other.selectedRole == selectedRole &&
          other.errorMessage == errorMessage &&
          other.pendingSignup == pendingSignup;

  @override
  int get hashCode => Object.hash(
    status,
    isSubmitting,
    user,
    selectedRole,
    errorMessage,
    pendingSignup,
  );
}
