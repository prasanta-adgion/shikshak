import 'class_occurrence.dart';
import 'class_slot.dart';
import 'class_timing.dart';
import 'date_range.dart';

/// One window of the teacher's calendar: the recurring [slots] that exist, and
/// the dated [occurrences] the server expanded from them across [range].
class ScheduleCalendar {
  const ScheduleCalendar({
    required this.range,
    this.slots = const [],
    this.occurrences = const [],
  });

  final DateRange range;

  /// Every recurrence the teacher has, whether or not it runs in [range].
  final List<ClassSlot> slots;

  /// Sorted by date, then start time — the repository guarantees it.
  final List<ClassOccurrence> occurrences;

  List<ClassOccurrence> occurrencesOn(DateTime day) {
    final date = DateRange.dateOnly(day);
    return [
      for (final occurrence in occurrences)
        if (occurrence.date == date) occurrence,
    ];
  }

  /// Class count per date, for the badges on the date strip. Dates with no
  /// classes are absent rather than mapped to zero.
  Map<DateTime, int> get countsByDate {
    final counts = <DateTime, int>{};
    for (final occurrence in occurrences) {
      counts.update(occurrence.date, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  int get classCount => occurrences.length;

  /// How many days in the range have at least one class.
  int get teachingDayCount => countsByDate.length;

  /// Total teaching time across the range. A class with no end time
  /// contributes nothing rather than being guessed at.
  Duration get totalDuration => occurrences.fold(
    Duration.zero,
    (total, occurrence) => total + (occurrence.duration ?? Duration.zero),
  );

  String get totalDurationLabel => totalDuration.scheduleLabel;

  /// The next class due after [now], or null once the range's classes are all
  /// behind it. Drives the "up next" line on the summary card.
  ClassOccurrence? nextUp({DateTime? now}) {
    final moment = now ?? DateTime.now();
    for (final occurrence in occurrences) {
      if (occurrence.endsAt.isAfter(moment)) return occurrence;
    }
    return null;
  }

  /// Slots that produced no class in [range], paired with the reason. Lets the
  /// screen explain a quiet week instead of leaving the teacher to wonder
  /// where a class they created went.
  List<(ClassSlot, SlotDormancy)> get dormantSlots {
    final running = {for (final occurrence in occurrences) occurrence.slotId};
    return [
      for (final slot in slots)
        if (!running.contains(slot.id))
          // Judged against the end of the window on screen, not today.
          if (slot.dormancy(asOf: range.to) case final reason?) (slot, reason),
    ];
  }

  /// True when the teacher has not created a single recurrence — distinct
  /// from a week that simply has no classes in it.
  bool get hasNoSlots => slots.isEmpty && occurrences.isEmpty;
}
