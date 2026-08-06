import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
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
}
