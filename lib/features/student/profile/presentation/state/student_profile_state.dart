import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/student_profile.dart';

class StudentProfileState {
  const StudentProfileState({
    this.profile,
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  final StudentProfile? profile;
  final bool isLoading;

  /// Separates "not asked yet" from "asked, and there is nothing" — the two
  /// look identical on [profile] alone but read very differently on screen.
  final bool hasLoaded;

  final ApiException? error;

  StudentProfileState copyWith({
    StudentProfile? profile,
    bool? isLoading,
    bool? hasLoaded,
    ApiException? error,
    bool clearError = false,
    bool clearProfile = false,
  }) => StudentProfileState(
    profile: clearProfile ? null : (profile ?? this.profile),
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
