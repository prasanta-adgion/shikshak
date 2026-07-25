import '../../domain/entities/password_reset_ticket.dart';

// TODO(api): field names unconfirmed with the backend. snake_case mirrors
// AuthResponseModel, which reads `access_token` / `refresh_token`.

/// Payload returned by the verify-reset-OTP endpoint.
class VerifyResetOtpResponseModel {
  const VerifyResetOtpResponseModel({required this.resetToken});

  final String resetToken;

  factory VerifyResetOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyResetOtpResponseModel(resetToken: json['reset_token'] as String);

  PasswordResetTicket toEntity() =>
      PasswordResetTicket(resetToken: resetToken);
}
