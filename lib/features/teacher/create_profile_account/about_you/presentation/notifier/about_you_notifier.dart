import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/network/api_result.dart';
import '../providers/about_you_providers.dart';
import '../state/about_you_state.dart';

class AboutYouNotifier extends Notifier<AboutYouState> {
  @override
  AboutYouState build() => const AboutYouState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getAboutYouUseCaseProvider).call();

    // The screen can be popped mid-request, which auto-disposes this
    // notifier — touching state after that throws.
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        state = AboutYouState(about: data);
      case ApiFailure(:final exception):
        state = state.copyWith(isLoading: false, error: exception);
    }
  }
}
