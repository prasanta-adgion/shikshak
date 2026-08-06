import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/network/api_result.dart';
import '../../domain/params/update_document_params.dart';
import '../providers/document_providers.dart';
import '../state/document_list_state.dart';

class DocumentListNotifier extends Notifier<DocumentListState> {
  @override
  DocumentListState build() => const DocumentListState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getDocumentsUseCaseProvider).call();

    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(items: data, isLoading: false);
      case ApiFailure(:final exception):
        state = state.copyWith(isLoading: false, error: exception);
    }
  }

  Future<bool> update(UpdateDocumentParams params) async {
    if (state.isUpdating) return false;
    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await ref.read(updateDocumentUseCaseProvider).call(params);

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(isUpdating: false);
        await load();
        return true;
      case ApiFailure(:final exception):
        state = state.copyWith(isUpdating: false, error: exception);
        return false;
    }
  }
}
