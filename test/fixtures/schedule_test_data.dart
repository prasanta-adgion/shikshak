import 'package:shiksak/features/teacher/class_schedule/domain/entities/class_mode.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/class_occurrence.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/class_slot.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/date_range.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/schedule_calendar.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/schedule_day.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/slot_time.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/notifier/class_schedule_notifier.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/notifier/class_slots_notifier.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/state/class_schedule_state.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/state/class_slots_state.dart';

/// Schedule data pinned to whichever week the suite runs in.
///
/// The screen reads the real clock for "today" and "this week", so the sample
/// is built relative to [DateRange.currentWeek] rather than from the fixture's
/// fixed August 2026 dates — otherwise every assertion about today, the week
/// header, or the current-week badge would depend on the day of the run.
class ScheduleSample {
  ScheduleSample._(this.week);

  factory ScheduleSample.currentWeek() =>
      ScheduleSample._(DateRange.currentWeek());

  final DateRange week;

  DateTime get monday => week.days[0];
  DateTime get wednesday => week.days[2];

  /// Two classes on two days, mirroring the shape of the real payload: an
  /// hour each, offline, colour-tagged.
  ScheduleCalendar get calendar => ScheduleCalendar(
    range: week,
    slots: [physicsSlot, englishSlot],
    occurrences: [physicsClass, logarithmClass],
  );

  /// The same recurrences with no classes in the window — what a week either
  /// side of the sample looks like.
  ScheduleCalendar quietWeek(DateRange range) =>
      ScheduleCalendar(range: range, slots: [physicsSlot, englishSlot]);

  ClassOccurrence get physicsClass => ClassOccurrence(
    slotId: 'physics',
    date: monday,
    title: 'Physics Classes',
    startTime: const SlotTime(hour: 9, minute: 0),
    endTime: const SlotTime(hour: 10, minute: 0),
    subjects: const ['Physics'],
    classes: const ['Class 11', 'Class 12'],
    mode: ClassMode.offline,
    colorTag: 'amber',
  );

  ClassOccurrence get logarithmClass => ClassOccurrence(
    slotId: 'maths',
    date: wednesday,
    title: 'Logarithm',
    startTime: const SlotTime(hour: 11, minute: 0),
    endTime: const SlotTime(hour: 12, minute: 0),
    subjects: const ['Mathematics'],
    classes: const ['Class 11'],
    mode: ClassMode.offline,
    colorTag: 'amber',
  );

  ClassSlot get physicsSlot => const ClassSlot(
    id: 'physics',
    title: 'Physics Classes',
    day: ScheduleDay.monday,
    startTime: SlotTime(hour: 9, minute: 0),
    endTime: SlotTime(hour: 10, minute: 0),
    subjects: ['Physics'],
    classes: ['Class 11', 'Class 12'],
    mode: ClassMode.offline,
    colorTag: 'amber',
  );

  /// Never runs in the sample week: paused, so it lands in the "not running"
  /// section whichever week is on screen.
  ClassSlot get englishSlot => const ClassSlot(
    id: 'english',
    title: 'English classes',
    day: ScheduleDay.tuesday,
    startTime: SlotTime(hour: 11, minute: 0),
    endTime: SlotTime(hour: 12, minute: 0),
    subjects: ['English'],
    classes: ['Class 9'],
    mode: ClassMode.offline,
    colorTag: 'emerald',
    isActive: false,
  );

  ClassScheduleState stateOn(DateTime date) => ClassScheduleState(
    range: week,
    selectedDate: date,
    calendar: calendar,
    hasLoaded: true,
  );

  /// Three recurrences across two days, one of them paused — enough for the
  /// All Slots tab to group, count, and explain.
  ClassSlotsState get slotsState => ClassSlotsState(
    slots: [physicsSlot, mathsSlot, englishSlot],
    hasLoaded: true,
  );

  /// Shares Monday with [physicsSlot] but starts later, so the within-day
  /// order is visible on screen.
  ClassSlot get mathsSlot => const ClassSlot(
    id: 'maths',
    title: 'Logarithm',
    day: ScheduleDay.monday,
    startTime: SlotTime(hour: 11, minute: 0),
    endTime: SlotTime(hour: 12, minute: 0),
    subjects: ['Mathematics'],
    classes: ['Class 11'],
    mode: ClassMode.offline,
    colorTag: 'amber',
  );
}

/// Serves fixed state so the screen lays out its real content, and never hits
/// the wire.
///
/// [calendarFor] stands in for the endpoint: when supplied, week navigation
/// re-populates from it, so paging can be exercised for real.
class SeededScheduleNotifier extends ClassScheduleNotifier {
  SeededScheduleNotifier(this.seed, {this.calendarFor});

  final ClassScheduleState seed;
  final ScheduleCalendar Function(DateRange range)? calendarFor;

  @override
  ClassScheduleState build() => seed;

  @override
  Future<void> load() async {
    final build = calendarFor;
    if (build == null) return;

    state = state.copyWith(
      calendar: build(state.range),
      isLoading: false,
      hasLoaded: true,
      clearError: true,
    );
  }
}

/// The All Slots equivalent of [SeededScheduleNotifier]: fixed state, and
/// never hits the wire.
class SeededSlotsNotifier extends ClassSlotsNotifier {
  SeededSlotsNotifier(this.seed);

  final ClassSlotsState seed;

  /// Slots the tab asked to flip, in tap order.
  final toggled = <String>[];

  @override
  ClassSlotsState build() => seed;

  @override
  Future<void> load() async {}

  @override
  Future<void> toggleActive(ClassSlot slot) async => toggled.add(slot.id);
}
