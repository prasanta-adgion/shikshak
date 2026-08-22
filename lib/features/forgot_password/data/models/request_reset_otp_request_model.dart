/// Body for the request-reset-OTP endpoint.
class RequestResetOtpRequestModel {
  const RequestResetOtpRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}
