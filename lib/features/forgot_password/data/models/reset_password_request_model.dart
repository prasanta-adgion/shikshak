/// Body for the reset endpoint, which verifies the OTP and stores the new
/// password in a single call.
class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'password': newPassword,
    'confirmPassword': confirmPassword,
  };
}
