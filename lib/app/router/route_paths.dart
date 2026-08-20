import '../../features/auth/domain/entities/user_role.dart';

abstract final class RoutePaths {
  static const String splash = '/';

  /// Role is chosen inline on the login screen, not via the route.
  static const String login = '/login';

  /// `:role` is `teacher` or `student` — see [UserRole.tryParse].
  static const String register = '/register/:role';

  static const String studentDashboard = '/student/dashboard';
  static const String teacherDashboard = '/teacher/dashboard';

  static String registerFor(UserRole role) => '/register/${role.name}';

  static const String signupOtp = '/signup/otp';

  static const String createTeacherAccount = '/signup/teacher-profile';

  //move to dashboard based on role
  static String dashboardFor(UserRole role) => switch (role) {
    UserRole.teacher => teacherDashboard,
    UserRole.student => studentDashboard,
  };
  static const String forgotPassword = '/password-forgot';

  /// Step 2 of the reset flow: OTP and the new password on one screen.
  static const String newPasswordSet = '/new-password-set';

  //teacher
  static const String createAccountScreenPath = '/create-teacher-account';

  /// Reopens one wizard step to change a saved section. The step travels as
  /// `extra` — see [RouteNames.editProfileSection].
  static const String editProfileSection = '/teacher/profile/edit';

  /// Form for a new recurring class slot, pushed from the Schedule tab.
  static const String createClassSlot = '/teacher/class-slot/create';
}

/// Route names used for named navigation and analytics screen tracking.
abstract final class RouteNames {
  //common screen
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String signupOtp = 'signupOtp';
  static const String createTeacherAccount = 'createTeacherAccount';
  static const String studentDashboard = 'studentDashboard';
  static const String teacherDashboard = 'teacherDashboard';
  static const String forgotPassword = 'passwordForgot';
  static const String newPasswordSet = 'newPasswordSet';

  //teacher
  static const String createAccountScreen = 'createAccount';
  static const String editProfileSection = 'editProfileSection';
  static const String createClassSlot = 'createClassSlot';
}
