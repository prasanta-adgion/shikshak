import '../../../../../../core/network/api_exception.dart';
import '../../data/model/education_response_model.dart';

/// The education rows the server has.
class EducationListState {
  final List<EducationItem> items;

  final bool isLoading;

  /// True while an edit is being saved — which row is being edited is the edit
  /// sheet's business, and only one is ever open.
  final bool isUpdating;

  final ApiException? error;

  const EducationListState({
    this.items = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
  });

  EducationListState copyWith({
    List<EducationItem>? items,
    bool? isLoading,
    bool? isUpdating,
    ApiException? error,
    bool clearError = false,
  }) => EducationListState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isUpdating: isUpdating ?? this.isUpdating,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
