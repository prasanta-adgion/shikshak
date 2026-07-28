import 'package:Shikshak/features/forgot_password/presentation/screens/forgot_password_email_put_screen.dart';
import 'package:Shikshak/features/forgot_password/presentation/screens/forgot_password_otp_screen.dart';
import 'package:Shikshak/features/forgot_password/presentation/screens/new_password_set.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/account_create/shared/presentation/pages/create_teacher_account_page.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/signup_otp_screen.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'page_transitions.dart';
import 'route_paths.dart';

abstract final class AppRouter {
  /// Guards `/register/:role` against garbage params.
  static String? _validateRoleParam(GoRouterState state) =>
      UserRole.tryParse(state.pathParameters['role']) == null
      ? RoutePaths.login
      : null;

  static UserRole _roleParam(GoRouterState state) =>
      UserRole.tryParse(state.pathParameters['role'])!;

  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        redirect: (context, state) => _validateRoleParam(state),
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: RegisterPage(role: _roleParam(state)),
        ),
      ),
      //signup — OTP entry
      GoRoute(
        path: RoutePaths.signupOtp,
        name: RouteNames.signupOtp,
        redirect: (context, state) {
          final email = state.extra;
          return email is! String || email.trim().isEmpty
              ? RoutePaths.login
              : null;
        },
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: SignupOtpScreen(email: state.extra! as String),
        ),
      ),

      //signup — teacher profile wizard
      GoRoute(
        path: RoutePaths.createTeacherAccount,
        name: RouteNames.createTeacherAccount,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const CreateTeacherAccountPage(),
        ),
      ),

      GoRoute(
        path: RoutePaths.studentDashboard,
        name: RouteNames.studentDashboard,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const StudentDashboardPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherDashboard,
        name: RouteNames.teacherDashboard,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const TeacherDashboardPage(),
        ),
      ),

      //forgot password
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),

      //forgot password — OTP entry
      GoRoute(
        path: RoutePaths.forgotPasswordOtp,
        name: RouteNames.forgotPasswordOtp,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const ForgotPasswordOtpScreen(),
        ),
      ),

      //new password set
      GoRoute(
        path: RoutePaths.newPasswordSet,
        name: RouteNames.newPasswordSet,
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const NewPasswordSet()),
      ),

      //all teacher screens ------------------------------------------------------------------

      //account create screen
      GoRoute(
        path: RoutePaths.createAccountScreenPath,
        name: RouteNames.createAccountScreen,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const CreateTeacherAccountPage(),
        ),
      ),
    ],
  );
}
