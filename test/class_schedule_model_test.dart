import 'package:Shikshak/features/teacher/class_schedule/data/model/class_calendar_response_model.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/model/class_occurrence_model.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/model/class_slot_model.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/class_mode.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/class_occurrence.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/class_slot.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/date_range.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/schedule_day.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/slot_time.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/class_calendar_response.dart';

ClassCalendarDataModel _data() =>
    ClassCalendarResponseModel.fromJson(classCalendarResponseJson()).data!;

List<ClassSlot> _slots() => [
  for (final model in _data().slots) ?model.toEntity(),
];

List<ClassOccurrence> _occurrences() => [
  for (final model in _data().occurrences) ?model.toEntity(),
];

void main() {
  group('ClassCalendarResponseModel', () {
    test('reads the range, the slots and the occurrences', () {
      final response = ClassCalendarResponseModel.fromJson(
        classCalendarResponseJson(),
      );
      final data = response.data!;

      expect(response.success, isTrue);
      expect(data.slots, hasLength(4));
      expect(data.occurrences, hasLength(3));
      expect(
        data.range!.toEntity(),
        DateRange(from: DateTime(2026, 8, 3), to: DateTime(2026, 8, 9)),
      );
    });

    test(
      'an unexpected data shape yields empty lists rather than throwing',
      () {
        final data = ClassCalendarResponseModel.fromJson({
          'success': true,
          'data': {'slots': 'not-a-list', 'occurrences': 42, 'range': 'nope'},
        }).data!;

        expect(data.slots, isEmpty);
        expect(data.occurrences, isEmpty);
        expect(data.range, isNull);
      },
    );

    test('a half-readable range is dropped rather than half-applied', () {
      expect(const DateRangeModel(from: '2026-08-03').toEntity(), isNull);
      expect(const DateRangeModel(to: 'never').toEntity(), isNull);
    });
  });

  group('ClassOccurrenceModel.toEntity', () {
    test('maps the wire fields onto the entity', () {
      final logarithm = _occurrences().first;

      expect(logarithm.slotId, '9cbf9d2b-ebfa-4884-a963-a672af7751eb');
      expect(logarithm.title, 'Logarithm');
      expect(logarithm.date, DateTime(2026, 8, 6));
      expect(logarithm.startTime, const SlotTime(hour: 9, minute: 0));
      expect(logarithm.endTime, const SlotTime(hour: 10, minute: 0));
      expect(logarithm.subjects, ['Mathematics']);
      expect(logarithm.classes, ['Class 11']);
      expect(logarithm.mode, ClassMode.offline);
      expect(logarithm.colorTag, 'amber');
      expect(logarithm.isException, isFalse);
    });

    test('drops a class that cannot be placed on the calendar', () {
      ClassOccurrence? entityFrom(Map<String, dynamic> json) =>
          ClassOccurrenceModel.fromJson(json).toEntity();

      expect(entityFrom({'startTime': '09:00'}), isNull);
      expect(entityFrom({'date': '2026-08-06'}), isNull);
      expect(entityFrom({'date': 'someday', 'startTime': '09:00'}), isNull);
      // Enough to place it: no end time is tolerated.
      expect(
        entityFrom({'date': '2026-08-06', 'startTime': '09:00'}),
        isNotNull,
      );
    });

    test('an occurrence spans its own start and end', () {
      final logarithm = _occurrences().first;

      expect(logarithm.startsAt, DateTime(2026, 8, 6, 9));
      expect(logarithm.endsAt, DateTime(2026, 8, 6, 10));
      expect(logarithm.isOn(DateTime(2026, 8, 6, 23, 30)), isTrue);
      expect(logarithm.isOn(DateTime(2026, 8, 7)), isFalse);
      expect(logarithm.isPast(now: DateTime(2026, 8, 6, 10, 1)), isTrue);
      expect(logarithm.isPast(now: DateTime(2026, 8, 6, 9, 30)), isFalse);
    });
  });

  group('ClassSlotModel.toEntity', () {
    test('maps the wire fields onto the entity', () {
      final physics = _slots().first;

      expect(physics.title, 'Physics Classes');
      expect(physics.day, ScheduleDay.sunday);
      expect(physics.startTime, const SlotTime(hour: 9, minute: 0));
      expect(physics.endTime, const SlotTime(hour: 10, minute: 0));
      expect(physics.mode, ClassMode.offline);
      expect(physics.validFrom, DateTime(2026, 8, 5));
      expect(physics.validUntil, isNull);
      expect(physics.isActive, isTrue);
    });

    test('dayOfWeek 0 is Sunday, as the occurrence dates confirm', () {
      final physics = _slots().first;
      final physicsClass = _occurrences().last;

      expect(physics.day, ScheduleDay.sunday);
      // The server expanded that same slot onto 9 Aug 2026 — a Sunday.
      expect(physicsClass.slotId, physics.id);
      expect(physicsClass.date.weekday, DateTime.sunday);
    });

    test('drops a row that cannot be placed on the week grid', () {
      ClassSlot? entityFrom(Map<String, dynamic> json) =>
          ClassSlotModel.fromJson(json).toEntity();

      expect(entityFrom({'id': '1', 'startTime': '09:00'}), isNull);
      expect(entityFrom({'id': '1', 'dayOfWeek': 2}), isNull);
      expect(
        entityFrom({'id': '1', 'dayOfWeek': 9, 'startTime': '09:00'}),
        isNull,
      );
      expect(
        entityFrom({'id': '1', 'dayOfWeek': 2, 'startTime': '09:00'}),
        isNotNull,
      );
    });

    test('an untitled class still renders under a fallback title', () {
      final slot = ClassSlotModel.fromJson({
        'dayOfWeek': 3,
        'startTime': '07:30',
        'title': '   ',
      }).toEntity();

      expect(slot!.title, 'Class');
    });
  });

  group('SlotTime', () {
    test('parses HH:mm and HH:mm:ss', () {
      expect(SlotTime.tryParse('09:05'), const SlotTime(hour: 9, minute: 5));
      expect(
        SlotTime.tryParse('23:59:30'),
        const SlotTime(hour: 23, minute: 59),
      );
    });

    test('rejects malformed and out-of-range values', () {
      for (final value in ['', '9', 'noon', '24:00', '09:60', 'aa:bb']) {
        expect(SlotTime.tryParse(value), isNull, reason: value);
      }
      expect(SlotTime.tryParse(null), isNull);
    });

    test('labels in 12-hour time', () {
      expect(const SlotTime(hour: 0, minute: 0).label, '12:00 AM');
      expect(const SlotTime(hour: 9, minute: 0).label, '9:00 AM');
      expect(const SlotTime(hour: 12, minute: 5).label, '12:05 PM');
      expect(const SlotTime(hour: 23, minute: 45).label, '11:45 PM');
    });
  });

  group('ClassTiming', () {
    ClassOccurrence classAt({
      SlotTime start = const SlotTime(hour: 9, minute: 0),
      SlotTime? end,
    }) => ClassOccurrence(
      slotId: '1',
      date: DateTime(2026, 8, 6),
      title: 'Class',
      startTime: start,
      endTime: end,
    );

    test('formats the duration', () {
      expect(
        classAt(end: const SlotTime(hour: 10, minute: 0)).durationLabel,
        '1h',
      );
      expect(
        classAt(end: const SlotTime(hour: 10, minute: 30)).durationLabel,
        '1h 30m',
      );
      expect(
        classAt(end: const SlotTime(hour: 9, minute: 45)).durationLabel,
        '45m',
      );
      expect(classAt().durationLabel, isEmpty);
    });

    test('a class ending before it starts runs past midnight', () {
      final late = classAt(
        start: const SlotTime(hour: 22, minute: 0),
        end: const SlotTime(hour: 1, minute: 0),
      );

      expect(late.duration, const Duration(hours: 3));
      expect(late.endsAt, DateTime(2026, 8, 7, 1));
    });

    test('shows the range, or the start alone when open-ended', () {
      expect(
        classAt(end: const SlotTime(hour: 10, minute: 0)).timeRangeLabel,
        '9:00 AM – 10:00 AM',
      );
      expect(classAt().timeRangeLabel, '9:00 AM');
    });
  });

  group('ClassSlot dormancy', () {
    ClassSlot slotWith({
      DateTime? validFrom,
      DateTime? validUntil,
      bool isActive = true,
    }) => ClassSlot(
      id: '1',
      title: 'Slot',
      day: ScheduleDay.monday,
      startTime: const SlotTime(hour: 9, minute: 0),
      validFrom: validFrom,
      validUntil: validUntil,
      isActive: isActive,
    );

    test('a running slot needs no explanation', () {
      expect(slotWith().dormancy(asOf: DateTime(2026, 8, 9)), isNull);
    });

    test('names why a slot is quiet', () {
      final weekEnd = DateTime(2026, 8, 9);

      expect(
        slotWith(isActive: false).dormancy(asOf: weekEnd),
        SlotDormancy.paused,
      );
      expect(
        slotWith(validUntil: DateTime(2026, 8, 1)).dormancy(asOf: weekEnd),
        SlotDormancy.ended,
      );
      expect(
        slotWith(validFrom: DateTime(2026, 8, 10)).dormancy(asOf: weekEnd),
        SlotDormancy.notStarted,
      );
      // Ends on the last day of the week: still running that week.
      expect(slotWith(validUntil: weekEnd).dormancy(asOf: weekEnd), isNull);
    });
  });

  group('venue', () {
    ClassOccurrence classWith({
      ClassMode? mode,
      String? venueName,
      String? venueAddress,
    }) => ClassOccurrence(
      slotId: '1',
      date: DateTime(2026, 8, 6),
      title: 'Class',
      startTime: const SlotTime(hour: 9, minute: 0),
      mode: mode,
      venueName: venueName,
      venueAddress: venueAddress,
    );

    test('joins the parts it has, and drops it for an online class', () {
      expect(
        classWith(mode: ClassMode.offline, venueName: 'Room 2').venueLabel,
        'Room 2',
      );
      expect(
        classWith(
          mode: ClassMode.offline,
          venueName: 'Room 2',
          venueAddress: 'Arambagh',
        ).venueLabel,
        'Room 2, Arambagh',
      );
      expect(
        classWith(mode: ClassMode.online, venueName: 'Room 2').venueLabel,
        isEmpty,
      );
    });
  });

  group('ScheduleDay.fromDateTime', () {
    test('maps Dart weekdays onto the Sunday-first wire index', () {
      expect(ScheduleDay.fromWire(0), ScheduleDay.sunday);
      expect(ScheduleDay.fromWire(6), ScheduleDay.saturday);
      expect(
        ScheduleDay.fromDateTime(DateTime(2026, 8, 2)),
        ScheduleDay.sunday,
      );
      expect(
        ScheduleDay.fromDateTime(DateTime(2026, 8, 3)),
        ScheduleDay.monday,
      );
      expect(
        ScheduleDay.fromDateTime(DateTime(2026, 8, 6)),
        ScheduleDay.thursday,
      );
      expect(
        ScheduleDay.fromDateTime(DateTime(2026, 8, 8)),
        ScheduleDay.saturday,
      );
    });
  });
}
