import '../../../../../core/network/api_exception.dart';

class CreateClassState {
  const CreateClassState({
    this.isSubmitting = false,
    this.isCreated = false,
    this.error,
  });

  final bool isSubmitting;

  /// The slot is on the server. The form is done with — the page pops on it.
  final bool isCreated;

  final ApiException? error;

  CreateClassState copyWith({
    bool? isSubmitting,
    bool? isCreated,
    ApiException? error,
    bool clearError = false,
  }) => CreateClassState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isCreated: isCreated ?? this.isCreated,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
