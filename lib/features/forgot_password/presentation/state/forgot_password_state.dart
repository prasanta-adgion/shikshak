/// Where the user is in the two-step reset flow. Screens observe this and
/// navigate; the notifier never calls GoRouter itself.
enum PasswordResetStage {
  /// Step 1 — entering the registered email address.
  enterEmail,

  /// Step 2 — entering the OTP together with the new password.
  resetPassword,

  /// Password changed — the flow is done.
  completed,
}

/// Immutable state for the whole password-reset feature.
class ForgotPasswordState {
  const ForgotPasswordState({
    this.stage = PasswordResetStage.enterEmail,
    this.isSubmitting = false,
    this.email,
    this.errorMessage,
  });

  final PasswordResetStage stage;

  /// True while a request is in flight.
  final bool isSubmitting;

  /// Captured in step 1 and replayed in step 2, so no screen needs a route
  /// parameter.
  final String? email;

  /// Last failure, surfaced by the UI as a snackbar. Cleared on the next
  /// submission.
  final String? errorMessage;

  static const _unset = Object();

  /// Nullable fields default to a sentinel so callers can either keep the
  /// current value (omit the argument) or clear it (pass null explicitly).
  ForgotPasswordState copyWith({
    PasswordResetStage? stage,
    bool? isSubmitting,
    Object? email = _unset,
    Object? errorMessage = _unset,
  }) => ForgotPasswordState(
    stage: stage ?? this.stage,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    email: identical(email, _unset) ? this.email : email as String?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgotPasswordState &&
          other.stage == stage &&
          other.isSubmitting == isSubmitting &&
          other.email == email &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(stage, isSubmitting, email, errorMessage);
}
