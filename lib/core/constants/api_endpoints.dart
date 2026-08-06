abstract final class ApiEndpoints {
  // Auth
  static const String login = 'api/v1/auth/login';
  static const String register = 'api/v1/auth/signup/request-otp';
  static const String otpVerify = 'api/v1/auth/signup/verify-otp';
  static const String resendOtp = 'api/v1/auth/signup/resend-otp';
  static const String refreshTokenGenerate = 'api/v1/auth/refresh-token';

  static const String requestPasswordResetOtp =
      'api/v1/auth/password/request-otp';
  static const String verifyPasswordResetOtp =
      'api/v1/auth/password/verify-otp';
  static const String resetPassword = 'api/v1/auth/password/reset';

  // Files — multipart upload returning the URL the profile payloads carry.
  static const String uploadAvatar = '/api/v1/user/profile/avatar';

  //upload all images or document
  static const String uploadFile = '/api/v1/upload/image';

  // Teacher account create / update / get
  static const String basicInfo = '/api/v1/user/teacher/profile/basic-info';
  static const String aboutYou = '/api/v1/user/teacher/profile/about-you';
  static const String education = '/api/v1/user/teacher/profile/education';
  static const String experience = '/api/v1/user/teacher/profile/experience';
  static const String documents = '/api/v1/user/teacher/profile/documents';
  static const String getProfile = '/api/v1/user/teacher/profile';
}
