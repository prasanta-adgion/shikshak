import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/theme/app_colors.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/date_range.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/schedule_calendar.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/schedule_calendar_tab.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/state/class_schedule_state.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/widgets/schedule_date_strip.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/widgets/schedule_week_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/schedule_test_data.dart';

void main() {
  final sample = ScheduleSample.currentWeek();

  Future<void> pumpSchedule(
    WidgetTester tester,
    ClassScheduleState seed, {
    ScheduleCalendar Function(DateRange)? calendarFor,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    // Tall, so the lazily built sliver list lays out in full rather than
    // stopping at the fold.
    tester.view.physicalSize = const Size(390, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          classScheduleNotifierProvider.overrideWith(
            () => SeededScheduleNotifier(seed, calendarFor: calendarFor),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ScheduleCalendarTab()),
        ),
      ),
    );
    await tester.pump();
  }

  /// The day-of-month pill for [date]. Day numbers are unique within a week,
  /// so this cannot collide with another pill.
  Finder datePill(DateTime date) => find.descendant(
    of: find.byType(ScheduleDateStrip),
    matching: find.text('${date.day}'),
  );

  group('ScheduleCalendarTab', () {
    testWidgets('names the week on screen', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      expect(find.text(ScheduleWeekHeader.label(sample.week)), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      // Nowhere to jump back to from the current week.
      expect(find.text('Back to today'), findsNothing);
    });

    testWidgets('summarises the week from its occurrences', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      // Two one-hour classes on two separate days.
      expect(find.text('2'), findsNWidgets(2));
      expect(find.text('2h'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Days'), findsOneWidget);
    });

    testWidgets('shows only the selected date\'s classes', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      expect(find.textContaining('Monday'), findsWidgets);
      expect(find.text('1 class'), findsOneWidget);
      expect(find.text('Physics Classes'), findsWidgets);
      expect(find.text('9:00 AM – 10:00 AM'), findsOneWidget);
      // Wednesday's class belongs to another date.
      expect(find.text('Logarithm'), findsNothing);
    });

    testWidgets('marks the dates that have classes in green', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      Color dayNumberColor(DateTime date) =>
          tester.widget<Text>(datePill(date)).style!.color!;

      // Wednesday carries a class and is not the selected date, so the green
      // is its own rather than borrowed from the filled pill.
      expect(dayNumberColor(sample.wednesday), AppColors.tertiary);
      // Tuesday has none.
      expect(dayNumberColor(sample.week.days[1]), isNot(AppColors.tertiary));
    });

    testWidgets('tapping a date in the strip swaps the list', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      await tester.tap(datePill(sample.wednesday));
      await tester.pumpAndSettle();

      expect(find.textContaining('Wednesday'), findsWidgets);
      expect(find.text('Logarithm'), findsOneWidget);
      expect(find.text('11:00 AM – 12:00 PM'), findsOneWidget);
    });

    testWidgets('renders the subject and class tags', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Class 11'), findsOneWidget);
      expect(find.text('Class 12'), findsOneWidget);
      expect(find.text('In person'), findsOneWidget);
    });

    testWidgets('a date with no classes gets an in-place note', (tester) async {
      // Tuesday: the sample has classes on Monday and Wednesday only.
      await pumpSchedule(tester, sample.stateOn(sample.week.days[1]));

      expect(find.text('No classes on Tuesday'), findsOneWidget);
      expect(find.text('0 classes'), findsOneWidget);
      // The week itself is not empty, so the full-screen state stays away.
      expect(find.text('No classes scheduled'), findsNothing);
    });

    testWidgets('explains a recurrence that produced no class', (tester) async {
      await pumpSchedule(tester, sample.stateOn(sample.monday));

      expect(find.text('Not running this week'), findsOneWidget);
      expect(find.text('English classes'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('pages to the next week and back to today', (tester) async {
      await pumpSchedule(
        tester,
        sample.stateOn(sample.monday),
        calendarFor: (range) =>
            range == sample.week ? sample.calendar : sample.quietWeek(range),
      );

      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();

      final nextWeek = sample.week.shiftedByWeeks(1);
      expect(find.text(ScheduleWeekHeader.label(nextWeek)), findsOneWidget);
      expect(find.text('Back to today'), findsOneWidget);
      // That week has no classes, but the recurrences are still explained.
      expect(find.text('Physics Classes'), findsNothing);
      expect(find.text('Not running this week'), findsOneWidget);

      await tester.tap(find.text('Back to today'));
      await tester.pumpAndSettle();

      expect(find.text(ScheduleWeekHeader.label(sample.week)), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
    });

    testWidgets('a teacher with no slots gets the empty state', (tester) async {
      await pumpSchedule(
        tester,
        ClassScheduleState(
          range: sample.week,
          selectedDate: sample.monday,
          calendar: ScheduleCalendar(range: sample.week),
          hasLoaded: true,
        ),
      );

      expect(find.text('No classes scheduled'), findsOneWidget);
      expect(find.text('This week'), findsNothing);
    });

    testWidgets('a load that failed outright offers a retry', (tester) async {
      await pumpSchedule(
        tester,
        ClassScheduleState(
          range: sample.week,
          selectedDate: sample.monday,
          hasLoaded: true,
          error: const ApiException(
            message: 'No internet connection. Check your network and retry.',
            type: ApiExceptionType.network,
          ),
        ),
      );

      expect(
        find.text('No internet connection. Check your network and retry.'),
        findsOneWidget,
      );
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows a spinner until the first load lands', (tester) async {
      await pumpSchedule(
        tester,
        ClassScheduleState(
          range: sample.week,
          selectedDate: sample.monday,
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No classes scheduled'), findsNothing);
    });
  });
}
