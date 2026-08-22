import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/theme/app_icons.dart';
import 'package:shiksak/features/teacher/create_class_slot/presentation/controller/class_slot_form_controller.dart';
import 'package:shiksak/features/teacher/create_class_slot/presentation/pages/create_class_slot_page.dart';

void main() {
  Future<void> pumpForm(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    // Tall, so the whole form lays out instead of stopping at the fold.
    tester.view.physicalSize = const Size(390, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // No provider overrides: these tests never get as far as a request, since
    // an invalid form stops at validation.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CreateClassSlotPage())),
    );
    // Settled, not a single frame: the route's entrance transition wraps the
    // page in an IgnorePointer until it finishes, and taps would not land.
    await tester.pumpAndSettle();
  }

  group('CreateClassSlotPage', () {
    testWidgets('lays out every section of the payload', (tester) async {
      await pumpForm(tester);

      expect(find.text('Class details'), findsOneWidget);
      expect(find.text('When it runs'), findsOneWidget);
      expect(find.text('Where it happens'), findsOneWidget);

      for (final label in [
        'Class title',
        'Description',
        'Subjects',
        'Classes',
        'Repeats on',
        'Class time',
        'Runs between',
        'Mode',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('starts in person, with the venue fields showing', (
      tester,
    ) async {
      await pumpForm(tester);

      expect(find.text('Venue name'), findsOneWidget);
      expect(find.text('Venue address'), findsOneWidget);
    });

    testWidgets('an online class drops the venue fields', (tester) async {
      await pumpForm(tester);

      // The InkWell rather than its label: a bare Text inside an ink
      // response is not itself the hit-test target.
      await tester.tap(find.widgetWithText(InkWell, 'Online'));
      await tester.pumpAndSettle();

      // Nowhere to go, so the fields are removed rather than greyed out.
      expect(find.text('Venue name'), findsNothing);
      expect(find.text('Venue address'), findsNothing);
    });

    testWidgets('submitting an empty form surfaces every requirement', (
      tester,
    ) async {
      await pumpForm(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Create Class'));
      await tester.pumpAndSettle();

      expect(find.text('Class title is required'), findsOneWidget);
      expect(find.text('Pick at least one subject'), findsOneWidget);
      expect(find.text('Pick at least one class'), findsOneWidget);
      expect(find.text('Choose the day it repeats on'), findsOneWidget);
      expect(find.text('Start time is required'), findsOneWidget);
      expect(find.text('End time is required'), findsOneWidget);
      expect(find.text('Start date is required'), findsOneWidget);
      expect(find.text('Venue name is required'), findsOneWidget);
    });

    testWidgets('the empty form is clean, so back leaves without asking', (
      tester,
    ) async {
      await pumpForm(tester);

      // No dialog: nothing has been typed.
      await tester.tap(find.widgetWithIcon(IconButton, AppIcons.back));
      await tester.pumpAndSettle();

      expect(find.text('Discard this class?'), findsNothing);
    });

    testWidgets('leaving a half-filled form asks first', (tester) async {
      await pumpForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Class 10 – Mathematics'),
        'Class 10 – Mathematics',
      );
      await tester.tap(find.widgetWithIcon(IconButton, AppIcons.back));
      await tester.pumpAndSettle();

      expect(find.text('Discard this class?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      // Still on the form, with the typing intact.
      expect(find.text('Class 10 – Mathematics'), findsOneWidget);
    });
  });

  group('ClassSlotFormController', () {
    late ClassSlotFormController controller;

    setUp(() => controller = ClassSlotFormController());
    tearDown(() => controller.dispose());

    test('holds no errors until the first submit', () {
      expect(controller.subjectsError, isNull);
      expect(controller.dayError, isNull);
      expect(controller.startTimeError, isNull);
      expect(controller.validFromError, isNull);
    });

    test('rejects an end time at or before the start', () {
      controller.showErrors.value = true;
      controller.startTime.value = const TimeOfDay(hour: 10, minute: 0);

      controller.endTime.value = const TimeOfDay(hour: 9, minute: 0);
      expect(controller.endTimeError, 'End time must be after the start time');

      controller.endTime.value = const TimeOfDay(hour: 10, minute: 0);
      expect(controller.endTimeError, 'End time must be after the start time');

      controller.endTime.value = const TimeOfDay(hour: 10, minute: 30);
      expect(controller.endTimeError, isNull);
    });

    test('rejects an end date before the start date', () {
      controller.showErrors.value = true;
      controller.validFrom.value = DateTime(2026, 8, 10);

      controller.validUntil.value = DateTime(2026, 8, 9);
      expect(
        controller.validUntilError,
        'End date cannot be before the start date',
      );

      // Optional: no end date is not an error.
      controller.validUntil.value = null;
      expect(controller.validUntilError, isNull);
    });

    test('an untouched form is clean, a typed one is dirty', () {
      expect(controller.isDirty, isFalse);

      controller.title.text = 'Class 10';
      expect(controller.isDirty, isTrue);
    });

    test('picking a value clears its error without another submit', () {
      controller.showErrors.value = true;
      expect(controller.subjectsError, isNotNull);

      controller.subjects.value = const ['Mathematics'];
      expect(controller.subjectsError, isNull);
    });
  });
}
