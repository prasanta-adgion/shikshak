import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/class_slot.dart';
import '../../domain/entities/class_timing.dart';
import '../../domain/entities/schedule_day.dart';

class ClassSlotsState {
  const ClassSlotsState({
    this.slots = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.togglingSlotIds = const {},
    this.error,
  });

  /// Already sorted by day then start time — the repository guarantees it.
  final List<ClassSlot> slots;

  final bool isLoading;

  /// Slots with an active/paused PATCH in flight. Per-slot rather than a
  /// single flag, so toggling one card does not freeze the rest.
  final Set<String> togglingSlotIds;

  /// Separates "not fetched yet" from "fetched and there is nothing", which
  /// decides between the spinner and the empty state.
  final bool hasLoaded;

  final ApiException? error;

  /// Slots grouped under the day they repeat on, Sunday first. Days with no
  /// slot are left out entirely rather than mapped to an empty list, so the
  /// list renders only the headings that carry something.
  Map<ScheduleDay, List<ClassSlot>> get slotsByDay {
    final grouped = <ScheduleDay, List<ClassSlot>>{};
    // Driven off the enum, not the data, so the groups come out in weekday
    // order however the list happens to be sorted.
    for (final day in ScheduleDay.values) {
      final daySlots = [
        for (final slot in slots)
          if (slot.day == day) slot,
      ];
      if (daySlots.isNotEmpty) grouped[day] = daySlots;
    }
    return grouped;
  }

  int get slotCount => slots.length;

  /// Slots that are switched on and inside their date window right now.
  int get activeCount => slots.where((slot) => slot.dormancy() == null).length;

  /// What a full week would come to if every recurrence ran. A slot with no
  /// end time contributes nothing rather than being guessed at.
  Duration get weeklyDuration => slots.fold(
    Duration.zero,
    (total, slot) => total + (slot.duration ?? Duration.zero),
  );

  String get weeklyDurationLabel => weeklyDuration.scheduleLabel;

  bool get isEmpty => slots.isEmpty;

  bool isToggling(String slotId) => togglingSlotIds.contains(slotId);

  ClassSlotsState copyWith({
    List<ClassSlot>? slots,
    bool? isLoading,
    bool? hasLoaded,
    Set<String>? togglingSlotIds,
    ApiException? error,
    bool clearError = false,
  }) => ClassSlotsState(
    slots: slots ?? this.slots,
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    togglingSlotIds: togglingSlotIds ?? this.togglingSlotIds,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
