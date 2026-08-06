import '../entities/experience_info.dart';

/// Everything the experience payload needs for one row, plus the id of the row
/// it belongs to.
class UpdateExperienceParams {
  const UpdateExperienceParams({
    required this.id,
    required this.experience,
    required this.teachingSubjects,
    required this.classesTaught,
  });

  final String id;

  final ExperienceInfo experience;

  /// Sent with every row, the same way the create call sends them.
  final List<String> teachingSubjects;
  final List<String> classesTaught;
}
