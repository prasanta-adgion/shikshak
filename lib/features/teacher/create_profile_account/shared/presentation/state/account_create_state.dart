import '../../../../../../core/network/api_exception.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/entities/teacher_profile_draft.dart';

class AccountCreateState {
  final ProfileStep step;
  final TeacherProfileDraft draft;

  final Map<ProfileStep, String> savedBodies;

  final bool isSubmitting;

  final bool isComplete;

  final ApiException? error;

  const AccountCreateState({
    this.step = ProfileStep.basicInfo,
    this.draft = const TeacherProfileDraft(),
    this.savedBodies = const {},
    this.isSubmitting = false,
    this.isComplete = false,
    this.error,
  });

  AccountCreateState copyWith({
    ProfileStep? step,
    TeacherProfileDraft? draft,
    Map<ProfileStep, String>? savedBodies,
    bool? isSubmitting,
    bool? isComplete,
    ApiException? error,
    bool clearError = false,
  }) => AccountCreateState(
    step: step ?? this.step,
    draft: draft ?? this.draft,
    savedBodies: savedBodies ?? this.savedBodies,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isComplete: isComplete ?? this.isComplete,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
