import '../../domain/entities/profile_step.dart';
import '../../domain/entities/teacher_profile_draft.dart';

/// Wizard state: which step is showing, and everything entered so far.
class AccountCreateState {
  const AccountCreateState({
    this.step = ProfileStep.basicInfo,
    this.draft = const TeacherProfileDraft(),
    this.isSubmitting = false,
  });

  final ProfileStep step;
  final TeacherProfileDraft draft;

  /// True while the current step's section is being saved.
  final bool isSubmitting;

  AccountCreateState copyWith({
    ProfileStep? step,
    TeacherProfileDraft? draft,
    bool? isSubmitting,
  }) => AccountCreateState(
    step: step ?? this.step,
    draft: draft ?? this.draft,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}
