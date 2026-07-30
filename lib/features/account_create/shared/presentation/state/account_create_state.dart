import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/entities/teacher_profile_draft.dart';

/// Wizard state: which step is showing, what has been entered, and what has
/// already reached the server.
class AccountCreateState {
  const AccountCreateState({
    this.step = ProfileStep.basicInfo,
    this.draft = const TeacherProfileDraft(),
    this.savedBodies = const {},
    this.isSubmitting = false,
    this.isComplete = false,
    this.error,
  });

  final ProfileStep step;
  final TeacherProfileDraft draft;

  /// Encoded body last accepted for each step. Its presence means "created",
  /// so the next save PATCHes; an identical body means there is nothing to
  /// send at all.
  final Map<ProfileStep, String> savedBodies;

  /// True while the current step's section is being saved.
  final bool isSubmitting;

  /// Set once the final section has been accepted.
  final bool isComplete;

  /// Last failure, for the page to surface. Cleared when a save starts.
  final ApiException? error;

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
