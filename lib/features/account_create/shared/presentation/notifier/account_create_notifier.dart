import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../about_you/domain/entities/about_you.dart';
import '../../../basic_info/domain/entities/basic_info.dart';
import '../../../documents/domain/entities/teacher_document.dart';
import '../../../education/domain/entities/education.dart';
import '../../../experience/domain/entities/experience_info.dart';
import '../../domain/entities/profile_step.dart';
import '../state/account_create_state.dart';

/// Owns the wizard: which step is showing, and the draft being filled in.
///
/// One setter per section, mirroring the one-endpoint-per-section split. Steps
/// hand back a whole section rather than field-by-field edits, so the object
/// posted later is exactly the object the screen built.
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

  void setSubmitting({required bool submitting}) =>
      state = state.copyWith(isSubmitting: submitting);
}
