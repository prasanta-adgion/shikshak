enum ScheduleDay {
  sunday(wireIndex: 0, label: 'Sunday', shortLabel: 'Sun'),
  monday(wireIndex: 1, label: 'Monday', shortLabel: 'Mon'),
  tuesday(wireIndex: 2, label: 'Tuesday', shortLabel: 'Tue'),
  wednesday(wireIndex: 3, label: 'Wednesday', shortLabel: 'Wed'),
  thursday(wireIndex: 4, label: 'Thursday', shortLabel: 'Thu'),
  friday(wireIndex: 5, label: 'Friday', shortLabel: 'Fri'),
  saturday(wireIndex: 6, label: 'Saturday', shortLabel: 'Sat');

  const ScheduleDay({
    required this.wireIndex,
    required this.label,
    required this.shortLabel,
  });

  final int wireIndex;
  final String label;
  final String shortLabel;

  /// Null for anything outside 0–6 — the caller decides whether an unplaceable
  /// slot is dropped or surfaced, rather than it silently landing on Sunday.
  static ScheduleDay? fromWire(int? value) {
    if (value == null) return null;
    for (final day in values) {
      if (day.wireIndex == value) return day;
    }
    return null;
  }

  /// Maps a calendar date onto the week strip.
  static ScheduleDay fromDateTime(DateTime date) =>
      values[date.weekday % DateTime.daysPerWeek];

  static ScheduleDay get today => fromDateTime(DateTime.now());
}
