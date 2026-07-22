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

  static String dashboardFor(UserRole role) => switch (role) {
    UserRole.teacher => teacherDashboard,
    UserRole.student => studentDashboard,
  };

  static const String otpVerify = '/otp-verify';

  static const String forgotPassword = '/password-forgot';
}

/// Route names used for named navigation and analytics screen tracking.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String studentDashboard = 'studentDashboard';
  static const String teacherDashboard = 'teacherDashboard';
  static const String otpVerify = 'otpVerify';
  static const String forgotPassword = 'passwordForgot';
}
