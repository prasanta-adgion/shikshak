import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';
import '../domain/entities/experience_info.dart';

class ExperienceSection implements ProfileSection, RepeatableSection {
  const ExperienceSection();

  @override
  ProfileStep get step => ProfileStep.experience;

  @override
  String get path => ApiEndpoints.experience;

  @override
  Map<String, dynamic> body(TeacherProfileDraft draft) {
    final experience = draft.experience;

    return {
      'teachingSubjects': draft.teachingSubjects,
      'classesTaught': draft.classesTaught,
      'totalTeachingExperience': experience.totalTeachingExperience,
      'currentJobTitle': experience.currentJobTitle,
      'currentInstitution': experience.currentInstitution,
      'experienceDetails': experience.experienceDetails,
      'isCurrent': experience.isCurrent,
      'startDate': experience.startDate == null
          ? null
          : DateTimeUtils.isoDate(experience.startDate!),
    };
  }

  /// Judged on the per-position fields only: total experience is a profile
  /// level answer that rides along with every entry.
  @override
  bool isEntryEmpty(TeacherProfileDraft draft) {
    final experience = draft.experience;
    return experience.currentJobTitle.isEmpty &&
        experience.currentInstitution.isEmpty &&
        experience.experienceDetails.isEmpty &&
        experience.startDate == null;
  }

  @override
  TeacherProfileDraft commitEntry(TeacherProfileDraft draft) => draft.copyWith(
    savedExperiences: [...draft.savedExperiences, draft.experience],
    // Total experience carries over — it describes the teacher, not the post.
    experience: ExperienceInfo(
      totalTeachingExperience: draft.experience.totalTeachingExperience,
    ),
  );
}
