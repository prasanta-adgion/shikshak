import 'package:Shikshak/features/forgot_password/presentation/screens/forgot_password_email_put_screen.dart';
import 'package:Shikshak/features/forgot_password/presentation/screens/new_password_set.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/signup_otp_screen.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/student/all_teachers/presentation/pages/all_teachers_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/student/single_teacher_details/presentation/pages/single_teacher_details_page.dart';
import '../../features/teacher/create_class_slot/presentation/pages/create_class_slot_page.dart';
import '../../features/teacher/create_profile_account/shared/domain/entities/profile_step.dart';
import '../../features/teacher/create_profile_account/shared/domain/entities/wizard_mode.dart';
import '../../features/teacher/create_profile_account/shared/presentation/notifier/account_create_notifier.dart';
import '../../features/teacher/create_profile_account/shared/presentation/pages/create_teacher_account_page.dart';
import '../../features/teacher/create_profile_account/shared/presentation/providers/account_create_providers.dart';
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
      //student — teacher discovery
      GoRoute(
        path: RoutePaths.studentAllTeachers,
        name: RouteNames.studentAllTeachers,
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const AllTeachersPage()),
      ),
      //student — one teacher's profile and classes
      GoRoute(
        path: RoutePaths.studentTeacherDetails,
        name: RouteNames.studentTeacherDetails,
        // An empty id would fetch `/teachers/` and 404 — back to the list,
        // which is where the only real ids come from.
        redirect: (context, state) =>
            (state.pathParameters['id'] ?? '').trim().isEmpty
            ? RoutePaths.studentAllTeachers
            : null,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: SingleTeacherDetailsPage(
            teacherId: state.pathParameters['id']!,
          ),
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

      //forgot password — OTP entry + new password, submitted together
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

      //edit one saved profile section — the step travels as `extra`
      GoRoute(
        path: RoutePaths.editProfileSection,
        name: RouteNames.editProfileSection,
        redirect: (context, state) =>
            state.extra is ProfileStep ? null : RoutePaths.teacherDashboard,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          // Scoped rather than seeded after the fact, so the wizard's first
          // build is already on this step and no other step ever mounts.
          child: ProviderScope(
            overrides: [
              accountCreateNotifierProvider.overrideWith(
                () => AccountCreateNotifier(
                  initialStep: state.extra! as ProfileStep,
                  initialMode: WizardMode.edit,
                ),
              ),
            ],
            child: const CreateTeacherAccountPage(),
          ),
        ),
      ),

      //teacher — new class slot
      GoRoute(
        path: RoutePaths.createClassSlot,
        name: RouteNames.createClassSlot,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const CreateClassSlotPage(),
        ),
      ),
    ],
  );
}
