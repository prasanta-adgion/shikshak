// TODO(api): field names unconfirmed with the backend.

/// Body for the verify-reset-OTP endpoint.
class VerifyResetOtpRequestModel {
  const VerifyResetOtpRequestModel({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}
