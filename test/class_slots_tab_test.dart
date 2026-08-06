import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/pages/class_slots_tab.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:Shikshak/features/teacher/class_schedule/presentation/state/class_slots_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/schedule_test_data.dart';

void main() {
  final sample = ScheduleSample.currentWeek();

  Future<void> pumpSlots(WidgetTester tester, ClassSlotsState seed) async {
    tester.view.devicePixelRatio = 1.0;
    // Tall, so the lazily built sliver list lays out in full rather than
    // stopping at the fold.
    tester.view.physicalSize = const Size(390, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          classSlotsNotifierProvider.overrideWith(
            () => SeededSlotsNotifier(seed),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ClassSlotsTab()),
        ),
      ),
    );
    await tester.pump();
  }

  group('ClassSlotsTab', () {
    testWidgets('summarises what the teacher has set up', (tester) async {
      await pumpSlots(tester, sample.slotsState);

      expect(find.text('Your class slots'), findsOneWidget);
      // Three slots, two of them running, three hours a week.
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3h'), findsOneWidget);
      expect(find.text('Slots'), findsOneWidget);
      expect(find.text('Per week'), findsOneWidget);
      // Only the stat says "Active": a running slot carries no badge, so the
      // word appears once on the whole screen.
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('calls out the slots that are not running', (tester) async {
      await pumpSlots(tester, sample.slotsState);

      expect(find.text('1 slot is paused or out of date'), findsOneWidget);
    });

    testWidgets('groups the slots under the day they repeat on', (
      tester,
    ) async {
      await pumpSlots(tester, sample.slotsState);

      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.text('2 slots'), findsOneWidget);
      expect(find.text('1 slot'), findsOneWidget);
      // A day with nothing on it gets no heading at all.
      expect(find.text('Wednesday'), findsNothing);
    });

    testWidgets('shows every slot, dormant ones included', (tester) async {
      await pumpSlots(tester, sample.slotsState);

      expect(find.text('Physics Classes'), findsOneWidget);
      expect(find.text('Logarithm'), findsOneWidget);
      // Paused, but still listed — the teacher has to be able to find it.
      expect(find.text('English classes'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('renders each slot\'s times, tags and mode', (tester) async {
      await pumpSlots(tester, sample.slotsState);

      expect(find.text('9:00 AM – 10:00 AM'), findsOneWidget);
      expect(find.text('11:00 AM – 12:00 PM'), findsNWidgets(2));
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('In person'), findsNWidgets(3));
    });

    testWidgets('a teacher with none gets the empty state', (tester) async {
      await pumpSlots(tester, const ClassSlotsState(hasLoaded: true));

      expect(find.text('No class slots yet'), findsOneWidget);
      expect(find.text('Your class slots'), findsNothing);
    });

    testWidgets('a load that failed outright offers a retry', (tester) async {
      await pumpSlots(
        tester,
        const ClassSlotsState(
          hasLoaded: true,
          error: ApiException(
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
      await pumpSlots(tester, const ClassSlotsState(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No class slots yet'), findsNothing);
    });
  });
}
