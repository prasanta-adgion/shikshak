import '../entities/education.dart';

/// One education row's payload, plus the id of the row it belongs to.
class UpdateEducationParams {
  const UpdateEducationParams({required this.id, required this.education});

  final String id;

  final Education education;
}
