import '../../../../../core/network/api_result.dart';
import '../entities/teacher_details.dart';

abstract interface class SingleTeacherRepository {
  /// One approved teacher by id, with their class slots.
  Future<ApiResult<TeacherDetails>> fetchTeacher(String teacherId);
}
