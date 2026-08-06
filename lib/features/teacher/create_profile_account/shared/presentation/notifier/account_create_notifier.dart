import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/network/request_body.dart';
import '../../../about_you/domain/entities/about_you.dart';
import '../../../basic_info/domain/entities/basic_info.dart';
import '../../../documents/domain/entities/teacher_document.dart';
import '../../../education/domain/entities/education.dart';
import '../../../experience/domain/entities/experience_info.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/entities/teacher_profile_draft.dart';
import '../../domain/entities/wizard_mode.dart';
import '../providers/account_create_providers.dart';
import '../state/account_create_state.dart';

class AccountCreateNotifier extends Notifier<AccountCreateState> {
  AccountCreateNotifier({
    this.initialStep,
    this.initialMode = WizardMode.create,
  });

  /// Where the wizard opens. Null is onboarding, which always starts at the
  /// first step; the edit route overrides this provider to name one section.
  final ProfileStep? initialStep;

  final WizardMode initialMode;

  @override
  AccountCreateState build() => AccountCreateState(
    step: initialStep ?? ProfileStep.basicInfo,
    mode: initialMode,
  );

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

  // ── Seeding from the server ────────────────────────────────────────────

  void hydrateBasicInfo(BasicInfo basicInfo) => _hydrate(
    ProfileStep.basicInfo,
    state.draft.copyWith(basicInfo: basicInfo),
  );

  void hydrateAboutYou(AboutYou aboutYou) =>
      _hydrate(ProfileStep.aboutYou, state.draft.copyWith(aboutYou: aboutYou));

  /// Fills a section in from what the server already holds, and records that
  /// body as saved. Two things follow from that: the next save PATCHes the
  /// existing section instead of POSTing a second one, and a step left
  /// untouched sends nothing at all.
  void _hydrate(ProfileStep step, TeacherProfileDraft draft) {
    final section = ref.read(profileSectionsProvider)[step];
    if (section == null) return;

    // Encoded exactly the way the save use case encodes it, or the comparison
    // there would never match.
    final encoded = jsonEncode(
      RequestBody.nullsAsEmptyStrings(section.body(draft)),
    );

    state = state.copyWith(
      draft: draft,
      savedBodies: {...state.savedBodies, step: encoded},
    );
  }

  // ── Saving ─────────────────────────────────────────────────────────────

  Future<bool> submitCurrentStep() => _save(advance: true);

  Future<bool> submitEntry() => _save(advance: false);

  /// Saves the section in place: no advance, no completion. Singleton sections
  /// PATCH here, because the step hydrated [AccountCreateState.savedBodies]
  /// from the server when it opened.
  Future<bool> submitEdit() => _save(advance: false, isEdit: true);

  Future<bool> _save({required bool advance, bool isEdit = false}) async {
    if (state.isSubmitting) return false;

    final step = state.step;
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await ref
        .read(saveProfileSectionUseCaseProvider)
        .call(
          step: step,
          draft: state.draft,
          lastSavedBody: state.savedBodies[step],
        );

    // The wizard can be popped mid-save, which auto-disposes this notifier —
    // touching state after that throws. The request itself still completed.
    if (!ref.mounted) return false;

    return result.fold(
      onSuccess: (outcome) {
        state = state.copyWith(
          isSubmitting: false,
          draft: outcome.draft,
          savedBodies: {...state.savedBodies, step: outcome.savedBody},
          isComplete: advance && step.isLast ? true : null,
          isEditSaved: isEdit ? true : null,
        );
        if (advance && !step.isLast) next();
        return true;
      },
      onFailure: (exception) {
        state = state.copyWith(isSubmitting: false, error: exception);
        return false;
      },
    );
  }
}
