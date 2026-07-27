import '../../domain/entities/password_reset_ticket.dart';

// TODO(api): field name unconfirmed with the backend.

/// Payload returned by the verify-reset-OTP endpoint.
class VerifyResetOtpResponseModel {
  const VerifyResetOtpResponseModel({required this.resetToken});

  final String resetToken;

  factory VerifyResetOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyResetOtpResponseModel(resetToken: json['reset_token'] as String);

  PasswordResetTicket toEntity() =>
      PasswordResetTicket(resetToken: resetToken);
}
