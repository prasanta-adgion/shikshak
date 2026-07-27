class ResendOtpRequestModel {
  /// Email address or mobile number the original code was sent to.
  final String inputEmailOrPhone;

  const ResendOtpRequestModel({required this.inputEmailOrPhone});

  Map<String, dynamic> toJson() => {'email': inputEmailOrPhone};
}
