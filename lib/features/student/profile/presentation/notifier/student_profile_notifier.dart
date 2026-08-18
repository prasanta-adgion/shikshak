import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../providers/student_profile_providers.dart';
import '../state/student_profile_state.dart';

class StudentProfileNotifier extends Notifier<StudentProfileState> {
  @override
  StudentProfileState build() => const StudentProfileState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getStudentProfileUseCaseProvider).call();

    // The tab can be left mid-request, which auto-disposes this notifier —
    // touching state after that throws.
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        state = StudentProfileState(profile: data, hasLoaded: true);
      case ApiFailure(:final exception):
        // The previous profile is kept: a failed refresh should not blank a
        // screen that was already showing good data.
        state = state.copyWith(
          isLoading: false,
          hasLoaded: true,
          error: exception,
        );
    }
  }

  /// Re-reads the profile, discarding any error from the last attempt.
  Future<void> refresh() async {
    state = state.copyWith(clearError: true);
    await load();
  }
}
