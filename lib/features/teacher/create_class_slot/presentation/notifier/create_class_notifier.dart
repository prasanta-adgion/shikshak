import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../../domain/params/create_class_params.dart';
import '../providers/create_class_providers.dart';
import '../state/create_class_state.dart';

class CreateClassNotifier extends Notifier<CreateClassState> {
  @override
  CreateClassState build() => const CreateClassState();

  Future<bool> submit(CreateClassParams params) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await ref.read(createClassUseCaseProvider)(params);

    // The form can be popped mid-request, which auto-disposes this notifier —
    // touching state after that throws.
    if (!ref.mounted) return false;

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(isSubmitting: false, isCreated: true);
        return true;
      case ApiFailure(:final exception):
        state = state.copyWith(isSubmitting: false, error: exception);
        return false;
    }
  }
}
