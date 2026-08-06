import 'class_mode.dart';
import 'slot_time.dart';

/// Time-of-day formatting shared by a recurring slot and by one dated
/// occurrence of it — both carry the same start/end pair and must read
/// identically wherever they appear.
mixin ClassTiming {
  SlotTime get startTime;

  /// Open-ended slots are tolerated: callers show the start alone.
  SlotTime? get endTime;

  /// Wall-clock length. A class that ends before it starts is read as running
  /// past midnight rather than as a negative duration.
  Duration? get duration {
    final end = endTime;
    if (end == null) return null;

    var minutes = end.minutesFromMidnight - startTime.minutesFromMidnight;
    if (minutes <= 0) minutes += Duration.minutesPerDay;
    return Duration(minutes: minutes);
  }

  /// `1h 30m`, `45m`, or empty when there is no end time.
  String get durationLabel => duration?.scheduleLabel ?? '';

  /// `9:00 AM – 10:00 AM`, or just the start when there is no end.
  String get timeRangeLabel {
    final end = endTime;
    return end == null ? startTime.label : '${startTime.label} – ${end.label}';
  }
}

/// Venue formatting, shared for the same reason as [ClassTiming].
mixin ClassVenue {
  ClassMode? get mode;
  String? get venueName;
  String? get venueAddress;

  /// The venue as one line, empty when the mode does not use one or the
  /// teacher never filled it in.
  String get venueLabel {
    final mode = this.mode;
    if (mode != null && !mode.hasVenue) return '';
    return [
      venueName,
      venueAddress,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
  }
}

extension ScheduleDurationLabel on Duration {
  /// `1h 30m`, `45m`, `2h`. Shared by a single class and by a week total so
  /// both read the same.
  String get scheduleLabel {
    final hours = inHours;
    final minutes = inMinutes % Duration.minutesPerHour;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
