class SignupOtpChallenge {
  const SignupOtpChallenge({required this.email, required this.expiresIn});

  /// Address the code was sent to — shown on the OTP screen.
  final String email;

  /// How long the code stays valid.
  final Duration expiresIn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignupOtpChallenge &&
          other.email == email &&
          other.expiresIn == expiresIn;

  @override
  int get hashCode => Object.hash(email, expiresIn);
}
// 