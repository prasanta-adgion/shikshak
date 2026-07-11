import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'page_transitions.dart';
import 'route_paths.dart';

/// Application router — a plain GoRouter configuration with no state
/// management attached.
///
/// Auth-driven navigation is performed explicitly by the screens that own
/// the transition:
///  * Splash navigates to a dashboard or role selection once the session
///    check resolves.
///  * Login/Register navigate to the role's dashboard on success.
///  * Logout navigates back to role selection.
abstract final class AppRouter {
  /// Guards `/login/:role` and `/register/:role` against garbage params.
  static String? _validateRoleParam(GoRouterState state) =>
      UserRole.tryParse(state.pathParameters['role']) == null
          ? RoutePaths.roleSelection
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
        path: RoutePaths.roleSelection,
        name: RouteNames.roleSelection,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const RoleSelectionPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        redirect: (context, state) => _validateRoleParam(state),
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: LoginPage(role: _roleParam(state)),
        ),
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
    ],
  );
}
