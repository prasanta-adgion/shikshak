// TODO(api): field names unconfirmed with the backend.

/// Body for the reset-password endpoint.
class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.email,
    required this.newPassword,
    this.resetToken,
  });

  final String email;
  final String newPassword;
  final String? resetToken;

  Map<String, dynamic> toJson() => {
    'email': email,
    'new_password': newPassword,
    // Omitted entirely when the backend tracks verification server-side.
    if (resetToken != null) 'reset_token': resetToken,
  };
}
