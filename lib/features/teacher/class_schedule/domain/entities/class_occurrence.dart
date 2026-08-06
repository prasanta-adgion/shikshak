import 'class_mode.dart';
import 'class_timing.dart';
import 'date_range.dart';
import 'slot_time.dart';

/// One class on one date — the server's expansion of a recurring slot across
/// the requested range.
///
/// It carries its own copy of the title, subjects, venue and so on rather than
/// pointing back at the slot, because a single occurrence can be edited
/// without touching the recurrence ([isException]).
class ClassOccurrence with ClassTiming, ClassVenue {
  const ClassOccurrence({
    required this.slotId,
    required this.date,
    required this.title,
    required this.startTime,
    this.endTime,
    this.description,
    this.subjects = const [],
    this.classes = const [],
    this.mode,
    this.venueName,
    this.venueAddress,
    this.colorTag,
    this.isException = false,
  });

  /// The recurrence this came from. Not unique: the same slot produces one of
  /// these per week.
  final String slotId;

  /// Date-only — the time of day lives in [startTime].
  final DateTime date;

  final String title;

  @override
  final SlotTime startTime;

  @override
  final SlotTime? endTime;

  final String? description;
  final List<String> subjects;
  final List<String> classes;

  @override
  final ClassMode? mode;

  @override
  final String? venueName;

  @override
  final String? venueAddress;

  final String? colorTag;

  /// True when this one class was changed away from its recurrence — moved,
  /// re-timed, or otherwise edited on its own.
  final bool isException;

  DateTime get startsAt => DateTime(
    date.year,
    date.month,
    date.day,
    startTime.hour,
    startTime.minute,
  );

  /// When the class finishes, rolling into the next day for a slot that runs
  /// past midnight.
  DateTime get endsAt => startsAt.add(duration ?? Duration.zero);

  bool isOn(DateTime day) => date == DateRange.dateOnly(day);

  /// Already finished. Used to dim today's earlier classes so the next one to
  /// teach is the one that stands out.
  bool isPast({DateTime? now}) => endsAt.isBefore(now ?? DateTime.now());
}
