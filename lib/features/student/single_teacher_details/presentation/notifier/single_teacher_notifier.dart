import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../providers/single_teacher_providers.dart';
import '../state/single_teacher_state.dart';

class SingleTeacherNotifier extends Notifier<SingleTeacherState> {
  @override
  SingleTeacherState build() => const SingleTeacherState();

  /// The profile behind [teacherId]. A no-op once that teacher is on screen,
  /// so rebuilding the page does not re-fetch — [refresh] is for that.
  Future<void> load(String teacherId) async {
    if (state.isLoading) return;
    if (state.hasLoaded && state.teacherId == teacherId) return;

    await _fetch(teacherId);
  }

  Future<void> refresh() => _fetch(state.teacherId);

  /// Adds or removes one class. A student can ask about several at once, so
  /// picking a second one does not drop the first.
  void toggleClass(String classId) {
    final selected = {...state.selectedClassIds};

    if (!selected.remove(classId)) selected.add(classId);

    state = state.copyWith(selectedClassIds: selected);
  }

  /// The header's one action: take everything on offer, or let it all go once
  /// everything is already taken.
  void toggleSelectAll() {
    state = state.copyWith(
      selectedClassIds: state.isEverythingSelected
          ? const {}
          : {for (final slot in state.availableClasses) slot.id},
    );
  }

  Future<void> _fetch(String teacherId) async {
    if (teacherId.isEmpty) return;

    state = state.copyWith(
      teacherId: teacherId,
      isLoading: true,
      clearError: true,
    );

    final result = await ref.read(getSingleTeacherUseCaseProvider)(teacherId);

    // The screen was left mid-request, which auto-disposes the notifier and
    // makes writing state throw.
    if (!ref.mounted) return;

    state = switch (result) {
      ApiSuccess(:final data) => state.copyWith(
        teacher: data,
        isLoading: false,
        hasLoaded: true,
        clearError: true,
        // Classes picked before a refresh may not have come back — ids
        // pointing at nothing would keep the button live with nothing
        // behind it.
        selectedClassIds: {
          for (final slot in data.availableClasses)
            if (state.selectedClassIds.contains(slot.id)) slot.id,
        },
      ),
      // Whatever is already on screen stays put: a failed refresh should not
      // blank a profile that was showing good data.
      ApiFailure(:final exception) => state.copyWith(
        isLoading: false,
        hasLoaded: true,
        error: exception,
      ),
    };
  }
}
