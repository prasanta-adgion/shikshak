import '../../../../../core/network/api_result.dart';
import '../entities/student_profile.dart';
import '../repositories/student_profile_repository.dart';

class GetStudentProfileUseCase {
  const GetStudentProfileUseCase(this._repository);

  final StudentProfileRepository _repository;

  Future<ApiResult<StudentProfile?>> call() => _repository.fetchProfile();
}
