/// How a class is delivered. The wire values are the ones the teacher's own
/// class-slot form writes.
enum ClassSlotMode {
  online(wire: 'online', label: 'Online'),
  inPerson(wire: 'offline', label: 'In person');

  const ClassSlotMode({required this.wire, required this.label});

  final String wire;
  final String label;

  /// Null for anything unrecognised, so the card omits the line rather than
  /// claiming a mode the server never sent.
  static ClassSlotMode? fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;

    for (final mode in values) {
      if (mode.wire == normalized) return mode;
    }
    return null;
  }

  /// Only an in-person class puts the two in the same room, so only it makes
  /// the venue worth showing.
  bool get hasVenue => this == inPerson;
}

/// One recurring class on a teacher's profile — the same weekday and time
/// every week — as a student sees it.
///
/// Deliberately separate from the teacher's own `ClassSlot`: this side only
/// reads, and needs labels rather than the scheduling machinery that drives
/// the teacher's week grid.
class TeacherClassSlot {
  const TeacherClassSlot({
    required this.id,
    required this.title,
    this.description,
    this.subjects = const [],
    this.classes = const [],
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.mode,
    this.venueName,
    this.venueAddress,
    this.price,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String? description;

  final List<String> subjects;
  final List<String> classes;

  /// 0 (Sunday) – 6 (Saturday), as the API numbers the week.
  final int? dayOfWeek;

  /// `HH:mm` or `HH:mm:ss`, straight off the wire.
  final String? startTime;
  final String? endTime;

  final ClassSlotMode? mode;
  final String? venueName;
  final String? venueAddress;

  /// What the class costs, per the teacher's own slot. Null when the row
  /// carried no amount at all — which is not the same as free.
  final num? price;

  /// A paused slot is still on the teacher's schedule but is not running.
  final bool isActive;

  static const List<String> _weekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// `Monday`, or null when the server sent something off the 0–6 week.
  String? get dayLabel {
    final day = dayOfWeek;
    if (day == null || day < 0 || day >= _weekdays.length) return null;
    return _weekdays[day];
  }

  /// `9:00 AM – 10:30 AM`, the start alone when there is no end, and null
  /// when neither is readable.
  String? get timeLabel {
    final start = _formatTime(startTime);
    if (start == null) return null;

    final end = _formatTime(endTime);
    return end == null ? start : '$start – $end';
  }

  /// The one line under the title: `Monday · 9:00 AM – 10:30 AM`.
  String get scheduleLabel =>
      [dayLabel, timeLabel].whereType<String>().join('  ·  ');

  /// Empty when the mode does not use a venue or the teacher left it blank.
  String get venueLabel {
    if (mode != null && !mode!.hasVenue) return '';

    return [venueName, venueAddress]
        .map((part) => part?.trim())
        .where((part) => part != null && part.isNotEmpty)
        .join(', ');
  }

  /// `₹500`, or `Free` for a zero amount. Null when no amount was sent, so
  /// the card stays quiet rather than implying the class costs nothing.
  String? get priceLabel {
    final amount = price;
    if (amount == null) return null;
    if (amount == 0) return 'Free';

    // Whole rupees: the API sends `500.00`, and `₹500.00` reads like a
    // billing statement rather than a price.
    final rounded = amount.round();
    return amount == rounded ? '₹$rounded' : '₹${amount.toStringAsFixed(2)}';
  }

  /// Title, subject or class — whichever the teacher actually filled in.
  String get displayTitle {
    final trimmed = title.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (subjects.isNotEmpty) return subjects.first;
    return 'Class';
  }

  /// `9:00 AM` from `09:00` / `09:00:00`. Null for a missing or malformed
  /// value, so one unreadable row does not take the card down with it.
  static String? _formatTime(String? value) {
    final parts = value?.split(':');
    if (parts == null || parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}
