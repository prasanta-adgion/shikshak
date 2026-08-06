import 'class_mode.dart';
import 'class_timing.dart';
import 'schedule_day.dart';
import 'slot_time.dart';

/// One recurring teaching slot: the same [day] and [startTime] every week,
/// for as long as the [validFrom]–[validUntil] window is open.
///
/// The dated instances the calendar renders are [ClassOccurrence]s, which the
/// server expands from these. A slot is the rule; an occurrence is a class.
class ClassSlot with ClassTiming, ClassVenue {
  const ClassSlot({
    required this.id,
    required this.title,
    required this.day,
    required this.startTime,
    this.endTime,
    this.description,
    this.subjects = const [],
    this.classes = const [],
    this.validFrom,
    this.validUntil,
    this.mode,
    this.venueName,
    this.venueAddress,
    this.colorTag,
    this.isActive = true,
  });

  final String id;
  final String title;

  /// A slot with no readable day or start time cannot be placed on the week
  /// grid at all, so both are required here and the model drops rows missing
  /// them rather than guessing.
  final ScheduleDay day;

  @override
  final SlotTime startTime;

  @override
  final SlotTime? endTime;

  final String? description;
  final List<String> subjects;
  final List<String> classes;

  /// The window the recurrence is live for. A null [validUntil] means it
  /// repeats indefinitely.
  final DateTime? validFrom;
  final DateTime? validUntil;

  @override
  final ClassMode? mode;

  @override
  final String? venueName;

  @override
  final String? venueAddress;

  /// Server-chosen palette name (`amber`, `emerald`, ...) used to colour-code
  /// the slot. Resolved to an actual theme colour in the presentation layer.
  final String? colorTag;

  final bool isActive;

  /// True once [validUntil] is in the past — the recurrence has run out even
  /// though the row is still on the schedule.
  bool isExpired({DateTime? asOf}) {
    final until = validUntil;
    if (until == null) return false;
    return until.isBefore(_startOfDay(asOf ?? DateTime.now()));
  }

  /// True while [validFrom] is still ahead — the first class has not happened.
  bool isUpcoming({DateTime? asOf}) {
    final from = validFrom;
    if (from == null) return false;
    return from.isAfter(_startOfDay(asOf ?? DateTime.now()));
  }

  /// Why this slot produced no class in the week on screen. Null when it is
  /// running normally, in which case its absence needs no explanation.
  ///
  /// [asOf] should be the end of the displayed week, not today: a slot that
  /// starts after the week ends is "not started yet" for that week even if it
  /// has started by now.
  SlotDormancy? dormancy({DateTime? asOf}) {
    if (!isActive) return SlotDormancy.paused;
    if (isExpired(asOf: asOf)) return SlotDormancy.ended;
    if (isUpcoming(asOf: asOf)) return SlotDormancy.notStarted;
    return null;
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// Why a slot is not producing classes.
enum SlotDormancy {
  paused('Paused'),
  ended('Ended'),
  notStarted('Starts later');

  const SlotDormancy(this.label);

  final String label;
}
