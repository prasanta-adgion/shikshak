import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/teacher_profile.dart';

class TeacherProfileState {
  const TeacherProfileState({
    this.profile,
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  final TeacherProfile? profile;
  final bool isLoading;

  final bool hasLoaded;

  final ApiException? error;

  TeacherProfileState copyWith({
    TeacherProfile? profile,
    bool? isLoading,
    bool? hasLoaded,
    ApiException? error,
    bool clearError = false,
    bool clearProfile = false,
  }) => TeacherProfileState(
    profile: clearProfile ? null : (profile ?? this.profile),
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
