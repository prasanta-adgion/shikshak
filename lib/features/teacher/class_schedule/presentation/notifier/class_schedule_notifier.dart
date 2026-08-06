import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../../domain/entities/date_range.dart';
import '../providers/class_schedule_providers.dart';
import '../state/class_schedule_state.dart';

class ClassScheduleNotifier extends Notifier<ClassScheduleState> {
  @override
  ClassScheduleState build() {
    final range = DateRange.currentWeek();
    return ClassScheduleState(
      range: range,
      selectedDate: DateRange.dateOnly(DateTime.now()),
    );
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final requested = state.range;
    final result = await ref.read(getClassCalendarUseCaseProvider)(requested);

    // The tab can be swapped mid-request, which auto-disposes this notifier —
    // touching state after that throws.
    if (!ref.mounted) return;

    // A week change that landed while this was in flight owns the screen now;
    // dropping the stale response stops it painting under the wrong dates.
    if (state.range != requested) return;

    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(
          calendar: data,
          isLoading: false,
          hasLoaded: true,
          clearError: true,
        );
      case ApiFailure(:final exception):
        state = state.copyWith(
          isLoading: false,
          hasLoaded: true,
          error: exception,
        );
    }
  }

  /// Re-reads the week on screen, discarding any error from the last attempt.
  Future<void> refresh() async {
    state = state.copyWith(clearError: true);
    await load();
  }

  void selectDate(DateTime date) {
    final day = DateRange.dateOnly(date);
    if (state.selectedDate == day) return;
    state = state.copyWith(selectedDate: day);
  }

  Future<void> showPreviousWeek() => _showWeek(state.range.shiftedByWeeks(-1));

  Future<void> showNextWeek() => _showWeek(state.range.shiftedByWeeks(1));

  /// Jumps back to the week containing today and selects it.
  Future<void> goToToday() async {
    final today = DateRange.dateOnly(DateTime.now());
    if (state.range.contains(today)) {
      selectDate(today);
      return;
    }
    await _showWeek(DateRange.weekOf(today), selected: today);
  }

  /// Moves the window, clearing the old week's classes so they are never drawn
  /// under the new week's dates, then loads.
  Future<void> _showWeek(DateRange range, {DateTime? selected}) async {
    final today = DateRange.dateOnly(DateTime.now());

    state = state.copyWith(
      range: range,
      // Landing on a week that contains today selects today; otherwise the
      // week opens on its first day.
      selectedDate: selected ?? (range.contains(today) ? today : range.from),
      clearCalendar: true,
      clearError: true,
      // A load already in flight belongs to the week being left, so this must
      // not be blocked by its `isLoading` guard.
      isLoading: false,
    );

    await load();
  }
}
