/// Where the user is in the reset flow. Screens observe this and navigate;
/// the notifier never calls GoRouter itself.
enum PasswordResetStage {
  /// Entering the registered email address.
  enterEmail,

  /// Entering the OTP that was emailed.
  verifyOtp,

  /// Choosing the new password.
  setPassword,

  /// Password changed — the flow is done.
  completed,
}

/// Immutable state for the whole password-reset feature.
class ForgotPasswordState {
  const ForgotPasswordState({
    this.stage = PasswordResetStage.enterEmail,
    this.isSubmitting = false,
    this.email,
    this.resetToken,
    this.errorMessage,
  });

  final PasswordResetStage stage;

  /// True while a request is in flight.
  final bool isSubmitting;

  /// Carried across all three steps so no screen needs a route parameter.
  final String? email;

  /// Issued by the verify-OTP step, replayed when setting the new password.
  final String? resetToken;

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
    Object? resetToken = _unset,
    Object? errorMessage = _unset,
  }) => ForgotPasswordState(
    stage: stage ?? this.stage,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    email: identical(email, _unset) ? this.email : email as String?,
    resetToken: identical(resetToken, _unset)
        ? this.resetToken
        : resetToken as String?,
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
          other.resetToken == resetToken &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(stage, isSubmitting, email, resetToken, errorMessage);
}
