import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/auth/domain/entities/user_entity.dart';
import 'package:Shikshak/features/auth/domain/entities/user_role.dart';
import 'package:Shikshak/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:Shikshak/features/auth/presentation/pages/login_page.dart';
import 'package:Shikshak/features/auth/presentation/pages/register_page.dart';
import 'package:Shikshak/features/auth/presentation/providers_di/auth_providers.dart';
import 'package:Shikshak/features/auth/presentation/state/auth_state.dart';
import 'package:Shikshak/features/forgot_password/presentation/screens/forgot_password_email_put_screen.dart';
import 'package:Shikshak/features/forgot_password/presentation/screens/forgot_password_otp_screen.dart';
import 'package:Shikshak/features/forgot_password/presentation/screens/new_password_set.dart';
import 'package:Shikshak/features/otp_verification/presentation/pages/otp_verify_screen.dart';
import 'package:Shikshak/features/student/presentation/pages/student_dashboard_page.dart';
import 'package:Shikshak/features/student/profile/data/model/student_profile_response_model.dart';
import 'package:Shikshak/features/student/profile/presentation/notifier/student_profile_notifier.dart';
import 'package:Shikshak/features/student/profile/presentation/pages/student_profile_page.dart';
import 'package:Shikshak/features/student/profile/presentation/providers/student_profile_providers.dart';
import 'package:Shikshak/features/student/profile/presentation/state/student_profile_state.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/class_slots_tab.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/teacher_schedule_page.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:Shikshak/features/teacher/create_class_slot/presentation/pages/create_class_slot_page.dart';
import 'package:Shikshak/features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'package:Shikshak/features/teacher/profile/data/model/teacher_profile_response_model.dart';
import 'package:Shikshak/features/teacher/profile/presentation/notifier/teacher_profile_notifier.dart';
import 'package:Shikshak/features/teacher/profile/presentation/pages/teacher_profile_page.dart';
import 'package:Shikshak/features/teacher/profile/presentation/providers/teacher_profile_providers.dart';
import 'package:Shikshak/features/teacher/profile/presentation/state/teacher_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/schedule_test_data.dart';
import 'fixtures/student_profile_response.dart';
import 'fixtures/teacher_profile_response.dart';

/// Windows the app must render cleanly in. Device class keys off the shortest
/// side, so both orientations of each form factor are covered.
const _windows = <String, Size>{
  'phone portrait': Size(390, 844),
  'phone landscape': Size(844, 390),
  'small phone': Size(320, 640),
  'tablet portrait': Size(800, 1280),
  'tablet landscape': Size(1280, 800),
};

/// Serves the sample payload so the profile screen lays out its real content
/// instead of a spinner. `load()` is a no-op: these tests never hit the wire.
class _SeededProfileNotifier extends TeacherProfileNotifier {
  @override
  TeacherProfileState build() => TeacherProfileState(
    profile: TeacherProfileResponseModel.fromJson(
      teacherProfileResponseJson(),
    ).data!.toEntity(),
    hasLoaded: true,
  );

  @override
  Future<void> load() async {}
}

/// Serves one of the sample student payloads. Seeded per screen entry rather
/// than once for the suite, so both ends of the range — a profile with
/// nothing filled in and one with everything — get laid out.
class _SeededStudentProfileNotifier extends StudentProfileNotifier {
  _SeededStudentProfileNotifier(this._json);

  final Map<String, dynamic> _json;

  @override
  StudentProfileState build() => StudentProfileState(
    profile: StudentProfileResponseModel.fromJson(_json).data!.toEntity(),
    hasLoaded: true,
  );

  @override
  Future<void> load() async {}
}

/// A nested scope, so each entry in the screen table can seed its own payload.
Widget _studentProfile(Map<String, dynamic> json) => ProviderScope(
  overrides: [
    studentProfileNotifierProvider.overrideWith(
      () => _SeededStudentProfileNotifier(json),
    ),
  ],
  child: const Scaffold(body: StudentProfilePage()),
);

/// Exercises the header's overflow guards with a name no card can fit.
Map<String, dynamic> _withLongName(Map<String, dynamic> json) {
  (json['data'] as Map<String, dynamic>)['user']['name'] =
      'Bartholomew Fitzgerald-Montgomery Wellington';
  return json;
}

/// Serves the sample schedule so the week header, the date strip, a full
/// class card and the "not running" section all lay out for real. Monday is
/// pinned so the day carrying a class is always the one on screen, whatever
/// day the suite runs.
final _schedule = ScheduleSample.currentWeek();

/// Seeds an authenticated session so dashboards render their real content.
/// The deliberately long name exercises the app-bar overflow guard.
class _SeededAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.authenticated,
    user: UserEntity(
      id: '1',
      fullName: 'Bartholomew Fitzgerald-Montgomery Wellington',
      email: 'bartholomew@example.com',
      mobileNumber: '9876543210',
      role: UserRole.student,
    ),
  );
}

void main() {
  Future<void> setWindow(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateNotifierProvider.overrideWith(_SeededAuthNotifier.new),
          teacherProfileNotifierProvider.overrideWith(
            _SeededProfileNotifier.new,
          ),
          classScheduleNotifierProvider.overrideWith(
            () => SeededScheduleNotifier(_schedule.stateOn(_schedule.monday)),
          ),
          classSlotsNotifierProvider.overrideWith(
            () => SeededSlotsNotifier(_schedule.slotsState),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
    await tester.pump();
  }

  final screens = <String, Widget Function()>{
    'LoginPage': () => const LoginPage(),
    'RegisterPage': () => const RegisterPage(role: UserRole.student),
    'OtpVerifyScreen': () => const OtpVerifyScreen(),
    'ForgotPasswordScreen': () => const ForgotPasswordScreen(),
    'ForgotPasswordOtpScreen': () => const ForgotPasswordOtpScreen(),
    'NewPasswordSet': () => const NewPasswordSet(),
    'StudentDashboardPage': () => const StudentDashboardPage(),
    'TeacherDashboardPage': () => const TeacherDashboardPage(),
    // Rendered as a dashboard tab, so it has no Scaffold of its own. Both
    // payloads are covered: a fresh profile shows the completion chips, a
    // finished one shows the sections they stand in for.
    'StudentProfilePage': () => _studentProfile(studentProfileResponseJson()),
    'StudentProfilePage (complete)': () =>
        _studentProfile(_withLongName(completeStudentProfileResponseJson())),
    // Rendered as a dashboard tab, so it has no Scaffold of its own — the
    // test supplies the Material ancestor its buttons need.
    'TeacherProfilePage': () => const Scaffold(body: TeacherProfilePage()),
    'TeacherSchedulePage': () => const Scaffold(body: TeacherSchedulePage()),
    // The shell opens on Calendar, so All Slots would never be laid out here
    // without an entry of its own.
    'ClassSlotsTab': () => const Scaffold(body: ClassSlotsTab()),
    'CreateClassSlotPage': () => const CreateClassSlotPage(),
  };

  group('renders without overflow', () {
    for (final MapEntry(key: screenName, value: build) in screens.entries) {
      for (final MapEntry(key: windowName, value: size) in _windows.entries) {
        testWidgets('$screenName on $windowName', (tester) async {
          await setWindow(tester, size);
          await pumpScreen(tester, build());

          // A RenderFlex overflow (or any layout assertion) surfaces here.
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('dark theme', () {
    for (final MapEntry(key: screenName, value: build) in screens.entries) {
      testWidgets('$screenName renders in dark mode', (tester) async {
        await setWindow(tester, const Size(390, 844));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateNotifierProvider.overrideWith(_SeededAuthNotifier.new),
              teacherProfileNotifierProvider.overrideWith(
                _SeededProfileNotifier.new,
              ),
              classScheduleNotifierProvider.overrideWith(
                () =>
                    SeededScheduleNotifier(_schedule.stateOn(_schedule.monday)),
              ),
              classSlotsNotifierProvider.overrideWith(
                () => SeededSlotsNotifier(_schedule.slotsState),
              ),
            ],
            child: MaterialApp(theme: AppTheme.dark, home: build()),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
