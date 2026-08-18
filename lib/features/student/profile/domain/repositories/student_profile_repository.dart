import '../../../../../core/network/api_result.dart';
import '../entities/student_profile.dart';

abstract interface class StudentProfileRepository {
  Future<ApiResult<StudentProfile?>> fetchProfile();
}
