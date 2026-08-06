import 'package:Shikshak/core/theme/app_icons.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/class_slots_tab.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/schedule_calendar_tab.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/teacher_schedule_page.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/schedule_test_data.dart';

void main() {
  final sample = ScheduleSample.currentWeek();

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          classScheduleNotifierProvider.overrideWith(
            () => SeededScheduleNotifier(sample.stateOn(sample.monday)),
          ),
          classSlotsNotifierProvider.overrideWith(
            () => SeededSlotsNotifier(sample.slotsState),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: TeacherSchedulePage()),
        ),
      ),
    );
    await tester.pump();
  }

  group('TeacherSchedulePage', () {
    testWidgets('opens on the Calendar tab', (tester) async {
      await pumpShell(tester);

      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('All Slots'), findsOneWidget);

      expect(find.byType(ScheduleCalendarTab), findsOneWidget);
      // The week view's own furniture, not the slots tab's.
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Your class slots'), findsNothing);
    });

    testWidgets('switching to All Slots swaps the body', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('All Slots'));
      await tester.pumpAndSettle();

      expect(find.byType(ClassSlotsTab), findsOneWidget);
      expect(find.text('Your class slots'), findsOneWidget);
      expect(find.text('This week'), findsNothing);
    });

    testWidgets('and back again, with each tab keeping its own content', (
      tester,
    ) async {
      await pumpShell(tester);

      await tester.tap(find.text('All Slots'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Your class slots'), findsNothing);
    });

    testWidgets('offers Create Class from either tab', (tester) async {
      await pumpShell(tester);

      // One button in the shared header, so it stays put across tabs.
      expect(find.text('Create Class'), findsOneWidget);
      expect(find.byIcon(AppIcons.addClass), findsOneWidget);

      await tester.tap(find.text('All Slots'));
      await tester.pumpAndSettle();

      expect(find.text('Create Class'), findsOneWidget);
    });

    testWidgets('Create Class is enabled', (tester) async {
      await pumpShell(tester);

      // Not tapped here: it pushes a route, which needs the real router. The
      // form's own test covers what opens.
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Create Class'),
      );

      expect(button.onPressed, isNotNull);
    });
  });
}
