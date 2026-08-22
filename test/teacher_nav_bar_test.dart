import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/theme/app_theme.dart';
import 'package:shiksak/features/auth/domain/entities/user_entity.dart';
import 'package:shiksak/features/auth/domain/entities/user_role.dart';
import 'package:shiksak/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:shiksak/features/auth/presentation/providers_di/auth_providers.dart';
import 'package:shiksak/features/auth/presentation/state/auth_state.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/pages/teacher_schedule_page.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:shiksak/features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'package:shiksak/features/teacher/presentation/widgets/teacher_nav_bar.dart';
import 'package:shiksak/features/teacher/profile/data/model/teacher_profile_response_model.dart';
import 'package:shiksak/features/teacher/profile/presentation/notifier/teacher_profile_notifier.dart';
import 'package:shiksak/features/teacher/profile/presentation/pages/teacher_profile_page.dart';
import 'package:shiksak/features/teacher/profile/presentation/providers/teacher_profile_providers.dart';
import 'package:shiksak/features/teacher/profile/presentation/state/teacher_profile_state.dart';

import 'fixtures/schedule_test_data.dart';
import 'fixtures/teacher_profile_response.dart';

class _SeededAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.authenticated,
    user: UserEntity(
      id: '1',
      fullName: 'Rahul Teacher',
      email: 'rahul.adgion@gmail.com',
      role: UserRole.teacher,
    ),
  );
}

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

void main() {
  final schedule = ScheduleSample.currentWeek();

  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    // Phone-width, so the bottom bar is used rather than the tablet rail
    // (the split keys off the shortest side). Tall, so the lazily built tab
    // bodies lay out in full instead of stopping at the fold.
    tester.view.physicalSize = const Size(390, 2000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateNotifierProvider.overrideWith(_SeededAuthNotifier.new),
          teacherProfileNotifierProvider.overrideWith(
            _SeededProfileNotifier.new,
          ),
          // Keeps the Schedule tab off the wire; the tab only needs to prove
          // it wires up to the real screen.
          classScheduleNotifierProvider.overrideWith(
            () => SeededScheduleNotifier(schedule.stateOn(schedule.monday)),
          ),
          classSlotsNotifierProvider.overrideWith(
            () => SeededSlotsNotifier(schedule.slotsState),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TeacherDashboardPage(),
        ),
      ),
    );
    await tester.pump();
  }

  /// The label inside the bar, not the same word wherever else it appears on
  /// the tab body.
  Finder barDestination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  group('TeacherNavBar', () {
    test('destinations follow declaration order', () {
      expect(TeacherTab.values.map((tab) => tab.label), [
        'Home',
        'Schedule',
        'Students',
        'Earnings',
        'Profile',
      ]);
      // AdaptiveNavigationScaffold selects by position, so the two must agree.
      expect(
        TeacherTab.destinations.map((destination) => destination.label),
        TeacherTab.values.map((tab) => tab.label),
      );
    });

    testWidgets('opens on Home', (tester) async {
      await pumpDashboard(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Recent Requests'), findsOneWidget);
    });

    testWidgets('switching to a placeholder tab swaps the body', (
      tester,
    ) async {
      await pumpDashboard(tester);

      await tester.tap(barDestination('Students'));
      await tester.pumpAndSettle();

      expect(
        find.text('All your enrolled students will be listed here.'),
        findsOneWidget,
      );
      expect(find.text('Recent Requests'), findsNothing);
    });

    testWidgets('the Schedule tab shows the real schedule screen', (
      tester,
    ) async {
      await pumpDashboard(tester);

      await tester.tap(barDestination('Schedule'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherSchedulePage), findsOneWidget);
      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Recent Requests'), findsNothing);
    });

    testWidgets('the Profile tab shows the real profile screen', (
      tester,
    ) async {
      await pumpDashboard(tester);

      await tester.tap(barDestination('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherProfilePage), findsOneWidget);
      expect(find.text('Basic Information'), findsOneWidget);
    });

    testWidgets('each placeholder keeps its own copy after the Profile tab', (
      tester,
    ) async {
      await pumpDashboard(tester);

      // Profile sits after the placeholders, so an off-by-one in the tab
      // lookup would surface as the wrong message here.
      for (final (label, message) in [
        ('Students', 'All your enrolled students will be listed here.'),
        ('Earnings', 'Detailed payout history and invoices are on the way.'),
      ]) {
        await tester.tap(barDestination(label));
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('selection survives going back to Home', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(barDestination('Earnings'));
      await tester.pumpAndSettle();
      await tester.tap(barDestination('Home'));
      await tester.pumpAndSettle();

      expect(find.text('Recent Requests'), findsOneWidget);
    });
  });
}
