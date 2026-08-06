import 'package:flutter/material.dart';

import '../../domain/entities/experience_info.dart';

class ExperienceFormController {
  ExperienceFormController({ExperienceInfo? initial})
    : jobTitle = TextEditingController(text: initial?.currentJobTitle ?? ''),
      institution = TextEditingController(
        text: initial?.currentInstitution ?? '',
      ),
      details = TextEditingController(text: initial?.experienceDetails ?? ''),
      totalExperience = ValueNotifier<String?>(
        initial?.totalTeachingExperience,
      ),
      startDate = ValueNotifier<DateTime?>(initial?.startDate),
      isCurrent = ValueNotifier<bool>(initial?.isCurrent ?? true);

  static const int detailsLimit = 500;

  final formKey = GlobalKey<FormState>();

  final TextEditingController jobTitle;
  final TextEditingController institution;
  final TextEditingController details;

  final ValueNotifier<String?> totalExperience;
  final ValueNotifier<DateTime?> startDate;
  final ValueNotifier<bool> isCurrent;

  /// The select and date fields have no validator of their own, so their
  /// errors stay hidden until the first submit.
  final showErrors = ValueNotifier<bool>(false);

  /// True when nothing has been typed — the teacher has filed what they wanted
  /// and left the form blank.
  bool get isEmpty =>
      jobTitle.text.trim().isEmpty &&
      institution.text.trim().isEmpty &&
      details.text.trim().isEmpty &&
      startDate.value == null;

  bool validate() {
    showErrors.value = true;

    final formValid = formKey.currentState?.validate() ?? false;
    return formValid &&
        totalExperience.value != null &&
        startDate.value != null;
  }

  ExperienceInfo toExperienceInfo() => ExperienceInfo(
    totalTeachingExperience: totalExperience.value,
    currentJobTitle: jobTitle.text.trim(),
    currentInstitution: institution.text.trim(),
    experienceDetails: details.text.trim(),
    isCurrent: isCurrent.value,
    startDate: startDate.value,
  );

  void setFrom(ExperienceInfo experience) {
    jobTitle.text = experience.currentJobTitle;
    institution.text = experience.currentInstitution;
    details.text = experience.experienceDetails;
    totalExperience.value = experience.totalTeachingExperience;
    startDate.value = experience.startDate;
    isCurrent.value = experience.isCurrent;
    showErrors.value = false;
  }

  /// Empties the position fields. Total experience stays: it describes the
  /// teacher, not the post.
  void reset() {
    formKey.currentState?.reset();
    jobTitle.clear();
    institution.clear();
    details.clear();
    startDate.value = null;
    isCurrent.value = true;
    showErrors.value = false;
  }

  void dispose() {
    jobTitle.dispose();
    institution.dispose();
    details.dispose();
    totalExperience.dispose();
    startDate.dispose();
    isCurrent.dispose();
    showErrors.dispose();
  }
}
