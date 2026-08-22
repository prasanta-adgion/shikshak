import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../../domain/entities/class_slot.dart';
import '../../domain/params/set_slot_active_params.dart';
import '../providers/class_schedule_providers.dart';
import '../state/class_slots_state.dart';

class ClassSlotsNotifier extends Notifier<ClassSlotsState> {
  @override
  ClassSlotsState build() => const ClassSlotsState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getClassSlotsUseCaseProvider)();

    // The tab can be swapped mid-request, which auto-disposes this notifier —
    // touching state after that throws.
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(
          slots: data,
          isLoading: false,
          hasLoaded: true,
          clearError: true,
        );
      case ApiFailure(:final exception):
        // The slots already on screen are kept: a failed refresh should not
        // blank a list that was rendering fine.
        state = state.copyWith(
          isLoading: false,
          hasLoaded: true,
          error: exception,
        );
    }
  }

  /// Re-reads the list, discarding any error from the last attempt.
  Future<void> refresh() async {
    state = state.copyWith(clearError: true);
    await load();
  }

  Future<void> toggleActive(ClassSlot slot) async {
    if (slot.id.isEmpty || state.isToggling(slot.id)) return;

    final target = !slot.isActive;

    //this is for update UI immediately;
    state = state.copyWith(
      slots: _withSlot(slot.id, slot.copyWith(isActive: target)),
      togglingSlotIds: {...state.togglingSlotIds, slot.id},
      clearError: true,
    );

    final result = await ref.read(classActiveInactiveToggleProvider)(
      SetSlotActiveParams(slotId: slot.id, isActive: target),
    );

    if (!ref.mounted) return;

    final stillToggling = {...state.togglingSlotIds}..remove(slot.id);

    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(
          // The echoed row wins where there is one; otherwise the flip
          // already on screen is what the server just stored.
          slots: data == null ? state.slots : _withSlot(slot.id, data),
          togglingSlotIds: stillToggling,
        );

        // A paused slot stops producing classes, and the calendar tab is
        // alive beside this one.
        ref.read(classScheduleNotifierProvider.notifier).refresh();

      case ApiFailure(:final exception):
        state = state.copyWith(
          slots: _withSlot(slot.id, slot),
          togglingSlotIds: stillToggling,
          error: exception,
        );
    }
  }

  /// The list with [slotId] swapped for [updated]. Order is untouched:
  /// nothing here changes the day or start time it was sorted on.
  List<ClassSlot> _withSlot(String slotId, ClassSlot updated) => [
    for (final slot in state.slots)
      if (slot.id == slotId) updated else slot,
  ];
}
