import '../../../../../core/network/api_result.dart';
import '../entities/teacher_details.dart';
import '../repositories/single_teacher_repository.dart';

class GetSingleTeacherUseCase {
  const GetSingleTeacherUseCase(this._repository);

  final SingleTeacherRepository _repository;

  Future<ApiResult<TeacherDetails>> call(String teacherId) =>
      _repository.fetchTeacher(teacherId);
}
