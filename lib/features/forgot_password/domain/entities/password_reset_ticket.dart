/// Proof that the user verified the reset OTP, exchanged for the right to set
/// a new password.
///
/// Framework-free by design (no json, no Flutter) — the data layer maps the
/// transport model onto this.
class PasswordResetTicket {
  const PasswordResetTicket({required this.resetToken});

  /// Short-lived token issued by the verify-OTP endpoint and replayed when
  /// submitting the new password.
  ///
  // TODO(api): confirm the server actually issues a token here. Some backends
  // keep the verified state server-side and expect only
  // {email, otp, newPassword} at reset time — if so, drop this entity and have
  // verifyResetOtp return void.
  final String resetToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordResetTicket && other.resetToken == resetToken;

  @override
  int get hashCode => resetToken.hashCode;
}
