import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/basic_info.dart';

/// The basic-info section as the server has it.
class BasicInfoState {
  /// `null` until the first load finishes, and after a load that found
  /// nothing saved.
  final BasicInfo? info;

  final bool isLoading;

  final ApiException? error;

  const BasicInfoState({this.info, this.isLoading = false, this.error});

  /// [info] is set through the constructor instead — a `copyWith` could never
  /// put it back to `null`.
  BasicInfoState copyWith({
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) => BasicInfoState(
    info: info,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}
