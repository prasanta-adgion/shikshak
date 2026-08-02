import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../providers/basic_info_providers.dart';
import '../state/basic_info_state.dart';

class BasicInfoNotifier extends Notifier<BasicInfoState> {
  @override
  BasicInfoState build() => const BasicInfoState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getBasicInfoUseCaseProvider).call();

    switch (result) {
      case ApiSuccess(:final data):
        state = BasicInfoState(info: data);
      case ApiFailure(:final exception):
        state = state.copyWith(isLoading: false, error: exception);
    }
  }
}
