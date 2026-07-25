abstract final class ApiEndpoints {
  // Auth
  static const String login = 'api/v1/auth/login';
  static const String register = 'api/v1/auth/signup/request-otp';
  static const String refreshToken = 'api/v1/auth/refresh';

  static const String requestPasswordResetOtp =
      'api/v1/auth/password/request-otp';
  static const String verifyPasswordResetOtp =
      'api/v1/auth/password/verify-otp';
  static const String resetPassword = 'api/v1/auth/password/reset';
}
