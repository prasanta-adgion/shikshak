import '../../features/auth/domain/entities/user_role.dart';

/// Central definition of every route path and name in the app.
///
/// Pages never hardcode locations — they always go through this class, so a
/// path change is a single-line edit.
abstract final class RoutePaths {
  static const String splash = '/';

  /// Role is chosen inline on the login screen, not via the route.
  static const String login = '/login';

  /// `:role` is `teacher` or `student` — see [UserRole.tryParse].
  static const String register = '/register/:role';

  static const String studentDashboard = '/student/dashboard';
  static const String teacherDashboard = '/teacher/dashboard';

  static String registerFor(UserRole role) => '/register/${role.name}';

  /// OTP entry for signup. Deliberately NOT `/register/otp`, which would be
  /// swallowed by the `:role` parameter of [register] and redirect to login.
  static const String signupOtp = '/signup/otp';

  static String dashboardFor(UserRole role) => switch (role) {
    UserRole.teacher => teacherDashboard,
    UserRole.student => studentDashboard,
  };

  // Password reset, in flow order. OTP entry is scoped to this flow: the
  // shared OtpVerifyScreen is wired by a per-flow adapter, and a callback
  // cannot be carried through a route path — so signup verification will get
  // its own sibling route rather than reusing this one.
  static const String forgotPassword = '/password-forgot';
  static const String forgotPasswordOtp = '/password-forgot/otp';
  static const String newPasswordSet = '/new-password-set';
}

/// Route names used for named navigation and analytics screen tracking.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String signupOtp = 'signupOtp';
  static const String studentDashboard = 'studentDashboard';
  static const String teacherDashboard = 'teacherDashboard';
  static const String forgotPassword = 'passwordForgot';
  static const String forgotPasswordOtp = 'passwordForgotOtp';
  static const String newPasswordSet = 'newPasswordSet';
}
