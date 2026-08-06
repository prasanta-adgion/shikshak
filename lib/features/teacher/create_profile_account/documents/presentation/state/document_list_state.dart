import '../../../../../../core/network/api_exception.dart';
import '../../data/model/document_response_model.dart';

/// The document rows the server has.
class DocumentListState {
  final List<DocumentItem> items;

  final bool isLoading;

  /// True while an edit is being saved — which row is being edited is the edit
  /// sheet's business, and only one is ever open.
  final bool isUpdating;

  final ApiException? error;

  const DocumentListState({
    this.items = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
  });

  DocumentListState copyWith({
    List<DocumentItem>? items,
    bool? isLoading,
    bool? isUpdating,
    ApiException? error,
    bool clearError = false,
  }) => DocumentListState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isUpdating: isUpdating ?? this.isUpdating,
    error: clearError ? null : (error ?? this.error),
  );
}
