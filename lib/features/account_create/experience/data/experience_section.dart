import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/date_time_picker_func.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';

/// Maps [ExperienceInfo] onto the experience payload:
///
/// ```json
/// { "teachingSubjects": [], "classesTaught": [], "totalTeachingExperience",
///   "currentJobTitle", "currentInstitution", "experienceDetails",
///   "isCurrent", "startDate" }
/// ```
///
/// `teachingSubjects` and `classesTaught` come off the draft rather than the
/// experience entity: About You captured them, and the teacher is only asked
/// once.
class ExperienceSection implements ProfileSection {
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
}
