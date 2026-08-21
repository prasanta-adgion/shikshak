import '../../../../../core/network/api_result.dart';
import '../entities/teachers_page.dart';
import '../params/teacher_query_params.dart';
import '../repositories/all_teachers_repository.dart';

class GetAllTeachersUseCase {
  const GetAllTeachersUseCase(this._repository);

  final AllTeachersRepository _repository;

  Future<ApiResult<TeachersPage>> call([
    TeacherQueryParams params = const TeacherQueryParams(),
  ]) => _repository.fetchTeachers(params);
}
