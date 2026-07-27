/// Body sent to the signup verify-OTP endpoint.
class VerifySignupOtpRequestModel {
  const VerifySignupOtpRequestModel({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}
