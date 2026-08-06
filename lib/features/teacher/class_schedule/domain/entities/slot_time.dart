/// A wall-clock time of day, in the `"09:00"` shape the schedule API sends.
///
/// Deliberately not Flutter's `TimeOfDay`: entities stay pure Dart. That also
/// keeps [label] formatting — hand-rolled, since the project has no `intl` —
/// next to the value it formats.
class SlotTime implements Comparable<SlotTime> {
  const SlotTime({required this.hour, required this.minute});

  /// 0–23.
  final int hour;

  /// 0–59.
  final int minute;

  /// Reads `HH:mm` or `HH:mm:ss`. Returns null for a missing or malformed
  /// value so one unreadable row cannot take down the whole schedule.
  static SlotTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return SlotTime(hour: hour, minute: minute);
  }

  int get minutesFromMidnight => hour * 60 + minute;

  /// `9:00 AM`
  String get label {
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  int compareTo(SlotTime other) =>
      minutesFromMidnight.compareTo(other.minutesFromMidnight);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => label;
}
