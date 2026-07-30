import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../about_you/domain/entities/about_you.dart';
import '../../../basic_info/domain/entities/basic_info.dart';
import '../../../documents/domain/entities/teacher_document.dart';
import '../../../education/domain/entities/education.dart';
import '../../../experience/domain/entities/experience_info.dart';
import '../../domain/entities/profile_step.dart';
import '../providers/account_create_providers.dart';
import '../state/account_create_state.dart';

class AccountCreateNotifier extends Notifier<AccountCreateState> {
  @override
  AccountCreateState build() => const AccountCreateState();

  // ── Navigation ─────────────────────────────────────────────────────────

  void goTo(ProfileStep step) => state = state.copyWith(step: step);

  void next() {
    if (state.step.isLast) return;
    state = state.copyWith(step: ProfileStep.values[state.step.index + 1]);
  }

  void previous() {
    if (state.step.isFirst) return;
    state = state.copyWith(step: ProfileStep.values[state.step.index - 1]);
  }

  // ── Sections ───────────────────────────────────────────────────────────

  void setBasicInfo(BasicInfo basicInfo) =>
      state = state.copyWith(draft: state.draft.copyWith(basicInfo: basicInfo));

  void setAboutYou(AboutYou aboutYou) =>
      state = state.copyWith(draft: state.draft.copyWith(aboutYou: aboutYou));

  void setExperience(ExperienceInfo experience) => state = state.copyWith(
    draft: state.draft.copyWith(experience: experience),
  );

  void setEducation(Education education) =>
      state = state.copyWith(draft: state.draft.copyWith(education: education));

  void setDocument(TeacherDocument document) =>
      state = state.copyWith(draft: state.draft.copyWith(document: document));

  // ── Saving ─────────────────────────────────────────────────────────────

  /// Sends the current step's section, then advances — or marks the wizard
  /// complete when it was the last one.
  ///
  /// A step whose data has not changed since its last save advances without a
  /// request. Failures leave the teacher exactly where they are, with [error]
  /// set for the page to surface.
  Future<void> submitCurrentStep() async {
    if (state.isSubmitting) return;

    final step = state.step;
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await ref
        .read(saveProfileSectionUseCaseProvider)
        .call(
          step: step,
          draft: state.draft,
          lastSavedBody: state.savedBodies[step],
        );

    result.fold(
      onSuccess: (outcome) {
        state = state.copyWith(
          isSubmitting: false,
          draft: outcome.draft,
          savedBodies: {...state.savedBodies, step: outcome.savedBody},
          isComplete: step.isLast ? true : null,
        );
        if (!step.isLast) next();
      },
      onFailure: (exception) =>
          state = state.copyWith(isSubmitting: false, error: exception),
    );
  }
}
