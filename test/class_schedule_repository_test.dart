import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/network/api_result.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/datasource/class_schedule_remote_datasource.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/model/class_calendar_response_model.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/model/class_occurrence_model.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/model/class_slot_model.dart';
import 'package:Shikshak/features/teacher/class_schedule/data/repository/class_schedule_repository_impl.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/class_slot.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/date_range.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/schedule_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/class_calendar_response.dart';

class _FakeDataSource implements ClassScheduleRemoteDataSource {
  _FakeDataSource({this.data = const ClassCalendarDataModel(), this.throws});

  final ClassCalendarDataModel data;
  final Object? throws;

  DateRange? requestedRange;

  @override
  Future<ClassCalendarDataModel> fetchWeeklyCalendar(DateRange range) async {
    requestedRange = range;
    final error = throws;
    if (error != null) throw error;
    return data;
  }

  /// The all-slots endpoint has its own tests; nothing here calls it.
  @override
  Future<List<ClassSlotModel>> fetchSlots() async => const [];
}

final _week = DateRange(from: DateTime(2026, 8, 3), to: DateTime(2026, 8, 9));

ClassCalendarDataModel _fixtureData() =>
    ClassCalendarResponseModel.fromJson(classCalendarResponseJson()).data!;

Future<ScheduleCalendar> _calendarFrom(_FakeDataSource remote) async {
  final result = await ClassScheduleRepositoryImpl(
    remoteDataSource: remote,
  ).fetchWeeklyCalendar(_week);
  return result.dataOrNull!;
}

void main() {
  group('ClassScheduleRepositoryImpl', () {
    test('passes the requested window to the datasource', () async {
      final remote = _FakeDataSource();

      await _calendarFrom(remote);

      expect(remote.requestedRange, _week);
    });

    test('orders occurrences by date then start time', () async {
      const data = ClassCalendarDataModel(
        occurrences: [
          // Deliberately out of order.
          ClassOccurrenceModel(
            slotId: 'friday',
            date: '2026-08-07',
            startTime: '09:00',
          ),
          ClassOccurrenceModel(
            slotId: 'late',
            date: '2026-08-06',
            startTime: '11:00',
          ),
          ClassOccurrenceModel(
            slotId: 'early',
            date: '2026-08-06',
            startTime: '08:00',
          ),
        ],
      );

      final calendar = await _calendarFrom(_FakeDataSource(data: data));

      expect(calendar.occurrences.map((one) => one.slotId), [
        'early',
        'late',
        'friday',
      ]);
    });

    test('keeps the real payload intact', () async {
      final calendar = await _calendarFrom(
        _FakeDataSource(data: _fixtureData()),
      );

      expect(calendar.range, _week);
      expect(calendar.slots, hasLength(4));
      expect(calendar.occurrences, hasLength(3));
      expect(calendar.occurrences.map((one) => one.date), [
        DateTime(2026, 8, 6),
        DateTime(2026, 8, 7),
        DateTime(2026, 8, 9),
      ]);
    });

    test(
      'falls back to the requested range when the server omits one',
      () async {
        final calendar = await _calendarFrom(_FakeDataSource());

        expect(calendar.range, _week);
      },
    );

    test(
      'drops rows it cannot place instead of failing the whole load',
      () async {
        const data = ClassCalendarDataModel(
          slots: [
            ClassSlotModel(id: 'good', dayOfWeek: 2, startTime: '09:00'),
            ClassSlotModel(id: 'no-day', startTime: '09:00'),
          ],
          occurrences: [
            ClassOccurrenceModel(
              slotId: 'good',
              date: '2026-08-06',
              startTime: '09:00',
            ),
            ClassOccurrenceModel(slotId: 'no-date', startTime: '09:00'),
          ],
        );

        final calendar = await _calendarFrom(_FakeDataSource(data: data));

        expect(calendar.slots.map((slot) => slot.id), ['good']);
        expect(calendar.occurrences.map((one) => one.slotId), ['good']);
      },
    );

    test('surfaces a datasource failure as ApiFailure', () async {
      const exception = ApiException(
        message: 'Server error. Try again later.',
        type: ApiExceptionType.server,
      );

      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: _FakeDataSource(throws: exception),
      ).fetchWeeklyCalendar(_week);

      expect(result, isA<ApiFailure<ScheduleCalendar>>());
      expect(
        (result as ApiFailure<ScheduleCalendar>).exception.message,
        exception.message,
      );
    });

    test('an unexpected error is wrapped rather than thrown', () async {
      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: _FakeDataSource(throws: StateError('boom')),
      ).fetchWeeklyCalendar(_week);

      expect(result, isA<ApiFailure<ScheduleCalendar>>());
    });
  });

  group('ScheduleCalendar', () {
    Future<ScheduleCalendar> fixtureCalendar() =>
        _calendarFrom(_FakeDataSource(data: _fixtureData()));

    test('sums the week the way the summary card reads it', () async {
      final calendar = await fixtureCalendar();

      expect(calendar.classCount, 3);
      expect(calendar.totalDurationLabel, '3h');
      expect(calendar.teachingDayCount, 3);
      expect(calendar.hasNoSlots, isFalse);
    });

    test('counts classes per date for the strip', () async {
      final calendar = await fixtureCalendar();

      expect(calendar.countsByDate, {
        DateTime(2026, 8, 6): 1,
        DateTime(2026, 8, 7): 1,
        DateTime(2026, 8, 9): 1,
      });
      expect(calendar.occurrencesOn(DateTime(2026, 8, 6)), hasLength(1));
      expect(calendar.occurrencesOn(DateTime(2026, 8, 5)), isEmpty);
    });

    test('finds the next class still to come', () async {
      final calendar = await fixtureCalendar();

      expect(calendar.nextUp(now: DateTime(2026, 8, 3))!.title, 'Logarithm');
      expect(
        calendar.nextUp(now: DateTime(2026, 8, 6, 10, 30))!.title,
        'Classesss',
      );
      expect(calendar.nextUp(now: DateTime(2026, 8, 10)), isNull);
    });

    test('explains the slot that produced no class this week', () async {
      final calendar = await fixtureCalendar();

      // English starts on the 10th — the Monday after this window.
      expect(calendar.dormantSlots, hasLength(1));
      final (slot, reason) = calendar.dormantSlots.single;
      expect(slot.title, 'English classes');
      expect(reason, SlotDormancy.notStarted);
    });

    test(
      'a teacher with nothing at all is distinct from a quiet week',
      () async {
        final empty = await _calendarFrom(_FakeDataSource());
        final quiet = await _calendarFrom(
          _FakeDataSource(
            data: const ClassCalendarDataModel(
              slots: [
                ClassSlotModel(id: '1', dayOfWeek: 2, startTime: '09:00'),
              ],
            ),
          ),
        );

        expect(empty.hasNoSlots, isTrue);
        expect(quiet.hasNoSlots, isFalse);
        expect(quiet.classCount, 0);
      },
    );
  });
}
