/// An inclusive span of calendar days, as the calendar endpoint's `from`/`to`
/// query parameters and its `range` response both express it.
///
/// Both ends are date-only: any time component is dropped on construction, so
/// two ranges for the same days always compare equal.
class DateRange {
  DateRange({required DateTime from, required DateTime to})
    : from = dateOnly(from),
      to = dateOnly(to);

  final DateTime from;
  final DateTime to;

  /// The Monday–Sunday week [date] falls in, which is how the schedule is
  /// paged. Day arithmetic goes through the [DateTime] constructor rather than
  /// [DateTime.add] so month and year boundaries normalise correctly.
  factory DateRange.weekOf(DateTime date) {
    final day = dateOnly(date);
    final start = DateTime(
      day.year,
      day.month,
      day.day - (day.weekday - DateTime.monday),
    );
    return DateRange(
      from: start,
      to: DateTime(start.year, start.month, start.day + 6),
    );
  }

  factory DateRange.currentWeek() => DateRange.weekOf(DateTime.now());

  /// Strips the time so a parsed timestamp and a picked date agree.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// The same span, moved [weeks] forward (or back, when negative).
  DateRange shiftedByWeeks(int weeks) => DateRange(
    from: DateTime(from.year, from.month, from.day + weeks * 7),
    to: DateTime(to.year, to.month, to.day + weeks * 7),
  );

  /// Every day in the span, inclusive of both ends. A reversed range yields
  /// just its start rather than an empty strip with nothing to select.
  List<DateTime> get days {
    if (to.isBefore(from)) return [from];
    return [for (var day = from; !day.isAfter(to); day = _nextDay(day)) day];
  }

  int get dayCount => days.length;

  bool contains(DateTime date) {
    final day = dateOnly(date);
    return !day.isBefore(from) && !day.isAfter(to);
  }

  /// `2026-08-03` — the shape the endpoint's query parameters take. Formatted
  /// here rather than through `DateTimeUtils` so entities stay pure Dart.
  String get isoFrom => _iso(from);
  String get isoTo => _iso(to);

  static DateTime _nextDay(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1);

  static String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => '$isoFrom..$isoTo';
}
