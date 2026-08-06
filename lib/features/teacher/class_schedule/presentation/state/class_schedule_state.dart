import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/class_occurrence.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/schedule_calendar.dart';

class ClassScheduleState {
  const ClassScheduleState({
    required this.range,
    required this.selectedDate,
    this.calendar,
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  /// The week being shown. Known before the response lands, so the header and
  /// the date strip can render while the classes are still in flight.
  final DateRange range;

  final DateTime selectedDate;

  /// Null until [range]'s classes arrive, and cleared again on every week
  /// change so last week's classes are never drawn under this week's dates.
  final ScheduleCalendar? calendar;

  final bool isLoading;

  /// True once any load has completed. Separates the very first paint from a
  /// week that simply has nothing in it, and keeps the header and strip in
  /// place while a later week loads.
  final bool hasLoaded;

  final ApiException? error;

  List<DateTime> get days => range.days;

  List<ClassOccurrence> get selectedDayClasses =>
      calendar?.occurrencesOn(selectedDate) ?? const [];

  Map<DateTime, int> get countsByDate => calendar?.countsByDate ?? const {};

  int get weekClassCount => calendar?.classCount ?? 0;

  String get weekDurationLabel => calendar?.totalDurationLabel ?? '';

  int get teachingDayCount => calendar?.teachingDayCount ?? 0;

  /// True when the teacher has created no recurrence at all — the whole-screen
  /// empty state, as opposed to a week that merely has no classes.
  bool get hasNoSlots => calendar?.hasNoSlots ?? false;

  /// The week's classes are still on their way.
  bool get isLoadingWeek => calendar == null && isLoading;

  bool get isCurrentWeek => range == DateRange.currentWeek();

  ClassScheduleState copyWith({
    DateRange? range,
    DateTime? selectedDate,
    ScheduleCalendar? calendar,
    bool? isLoading,
    bool? hasLoaded,
    ApiException? error,
    bool clearError = false,
    bool clearCalendar = false,
  }) => ClassScheduleState(
    range: range ?? this.range,
    selectedDate: selectedDate ?? this.selectedDate,
    calendar: clearCalendar ? null : (calendar ?? this.calendar),
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
