import '../../features/auth/domain/entities/user_role.dart';

/// Central definition of every route path and name in the app.
///
/// Pages never hardcode locations — they always go through this class, so a
/// path change is a single-line edit.
abstract final class RoutePaths {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';

  /// `:role` is `teacher` or `student` — see [UserRole.tryParse].
  static const String login = '/login/:role';
  static const String register = '/register/:role';

  static const String studentDashboard = '/student/dashboard';
  static const String teacherDashboard = '/teacher/dashboard';

  static String loginFor(UserRole role) => '/login/${role.name}';

  static String registerFor(UserRole role) => '/register/${role.name}';

  static String dashboardFor(UserRole role) => switch (role) {
        UserRole.teacher => teacherDashboard,
        UserRole.student => studentDashboard,
      };
}

/// Route names used for named navigation and analytics screen tracking.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String roleSelection = 'roleSelection';
  static const String login = 'login';
  static const String register = 'register';
  static const String studentDashboard = 'studentDashboard';
  static const String teacherDashboard = 'teacherDashboard';
}
