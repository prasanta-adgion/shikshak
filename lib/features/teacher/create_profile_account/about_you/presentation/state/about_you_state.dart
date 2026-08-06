import '../../../../../../core/network/api_exception.dart';
import '../../domain/entities/about_you.dart';

/// The about-you section as the server has it.
class AboutYouState {
  /// `null` until the first load finishes, and after a load that found
  /// nothing saved.
  final AboutYou? about;

  final bool isLoading;

  final ApiException? error;

  const AboutYouState({this.about, this.isLoading = false, this.error});

  /// [about] is set through the constructor instead — a `copyWith` could never
  /// put it back to `null`.
  AboutYouState copyWith({
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) => AboutYouState(
    about: about,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}
