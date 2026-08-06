import '../../../../../../core/utils/date_time_picker_func.dart';
import '../../domain/entities/experience_info.dart';

class ExperienceRequestModel {
  const ExperienceRequestModel({
    required this.teachingSubjects,
    required this.classesTaught,
    required this.experience,
  });

  final List<String> teachingSubjects;
  final List<String> classesTaught;

  final ExperienceInfo experience;

  Map<String, dynamic> toJson() => {
    'teachingSubjects': teachingSubjects,
    'classesTaught': classesTaught,
    'totalTeachingExperience': experience.totalTeachingExperience ?? '',
    'currentJobTitle': experience.currentJobTitle,
    'currentInstitution': experience.currentInstitution,
    'experienceDetails': experience.experienceDetails,
    'isCurrent': experience.isCurrent,
    'startDate': experience.startDate == null
        ? ''
        : DateTimeUtils.isoDate(experience.startDate!),
  };
}
