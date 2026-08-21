import '../../../../../core/network/api_result.dart';
import '../entities/teachers_page.dart';
import '../params/teacher_query_params.dart';

abstract interface class AllTeachersRepository {
  Future<ApiResult<TeachersPage>> fetchTeachers(TeacherQueryParams params);
}
