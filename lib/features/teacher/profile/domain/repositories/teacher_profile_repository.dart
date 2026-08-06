import '../../../../../core/network/api_result.dart';
import '../entities/teacher_profile.dart';

abstract interface class TeacherProfileRepository {
  Future<ApiResult<TeacherProfile?>> fetchProfile();
}
