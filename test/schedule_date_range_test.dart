import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/date_range.dart';

void main() {
  group('DateRange.weekOf', () {
    test('spans Monday to Sunday around any day in the week', () {
      final monday = DateTime(2026, 8, 3);
      final sunday = DateTime(2026, 8, 9);

      for (final day in [
        monday,
        DateTime(2026, 8, 6),
        // A time of day must not push the week out by one.
        DateTime(2026, 8, 9, 23, 59),
      ]) {
        final week = DateRange.weekOf(day);
        expect(week.from, monday, reason: '$day');
        expect(week.to, sunday, reason: '$day');
      }
    });

    test('handles a week that straddles a month and a year', () {
      final newYear = DateRange.weekOf(DateTime(2027, 1, 1));

      expect(newYear.from, DateTime(2026, 12, 28));
      expect(newYear.to, DateTime(2027, 1, 3));
    });
  });

  group('DateRange', () {
    final week = DateRange(
      from: DateTime(2026, 8, 3),
      to: DateTime(2026, 8, 9),
    );

    test('lists every day inclusive of both ends', () {
      expect(week.days, hasLength(7));
      expect(week.days.first, DateTime(2026, 8, 3));
      expect(week.days.last, DateTime(2026, 8, 9));
    });

    test('shifts by whole weeks across a month boundary', () {
      final next = week.shiftedByWeeks(1);
      final back = week.shiftedByWeeks(-1);

      expect(next.from, DateTime(2026, 8, 10));
      expect(next.to, DateTime(2026, 8, 16));
      expect(back.from, DateTime(2026, 7, 27));
      expect(back.to, DateTime(2026, 8, 2));
    });

    test('knows which dates it holds, ignoring the time of day', () {
      expect(week.contains(DateTime(2026, 8, 3)), isTrue);
      expect(week.contains(DateTime(2026, 8, 9, 18, 30)), isTrue);
      expect(week.contains(DateTime(2026, 8, 2, 23, 59)), isFalse);
      expect(week.contains(DateTime(2026, 8, 10)), isFalse);
    });

    test('formats both ends for the query string', () {
      expect(week.isoFrom, '2026-08-03');
      expect(week.isoTo, '2026-08-09');
      expect(
        DateRange(
          from: DateTime(2026, 1, 5),
          to: DateTime(2026, 1, 11),
        ).isoFrom,
        '2026-01-05',
      );
    });

    test('drops the time so equal days compare equal', () {
      expect(
        DateRange(
          from: DateTime(2026, 8, 3, 9),
          to: DateTime(2026, 8, 9, 17, 45),
        ),
        week,
      );
    });

    test('a reversed range yields its start rather than nothing to select', () {
      final reversed = DateRange(
        from: DateTime(2026, 8, 9),
        to: DateTime(2026, 8, 3),
      );

      expect(reversed.days, [DateTime(2026, 8, 9)]);
    });
  });
}
