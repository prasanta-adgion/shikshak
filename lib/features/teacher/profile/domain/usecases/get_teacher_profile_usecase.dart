import '../../../../../core/network/api_result.dart';
import '../entities/teacher_profile.dart';
import '../repositories/teacher_profile_repository.dart';

class GetTeacherProfileUseCase {
  final TeacherProfileRepository _repository;

  const GetTeacherProfileUseCase(this._repository);

  Future<ApiResult<TeacherProfile?>> call() => _repository.fetchProfile();
}
