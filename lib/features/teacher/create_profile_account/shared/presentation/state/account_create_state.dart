import '../../../../../../core/network/api_exception.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/entities/teacher_profile_draft.dart';
import '../../domain/entities/wizard_mode.dart';

class AccountCreateState {
  final ProfileStep step;
  final TeacherProfileDraft draft;

  final Map<ProfileStep, String> savedBodies;

  final bool isSubmitting;

  final bool isComplete;

  /// Onboarding, or a return visit to change one section.
  final WizardMode mode;

  /// An edit was saved — the page's cue to pop back to the profile. The
  /// [mode] counterpart of [isComplete].
  final bool isEditSaved;

  final ApiException? error;

  const AccountCreateState({
    this.step = ProfileStep.basicInfo,
    this.draft = const TeacherProfileDraft(),
    this.savedBodies = const {},
    this.isSubmitting = false,
    this.isComplete = false,
    this.mode = WizardMode.create,
    this.isEditSaved = false,
    this.error,
  });

  bool get isEditing => mode == WizardMode.edit;

  AccountCreateState copyWith({
    ProfileStep? step,
    TeacherProfileDraft? draft,
    Map<ProfileStep, String>? savedBodies,
    bool? isSubmitting,
    bool? isComplete,
    WizardMode? mode,
    bool? isEditSaved,
    ApiException? error,
    bool clearError = false,
  }) => AccountCreateState(
    step: step ?? this.step,
    draft: draft ?? this.draft,
    savedBodies: savedBodies ?? this.savedBodies,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isComplete: isComplete ?? this.isComplete,
    mode: mode ?? this.mode,
    isEditSaved: isEditSaved ?? this.isEditSaved,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
