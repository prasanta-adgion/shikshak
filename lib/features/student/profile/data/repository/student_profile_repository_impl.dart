import '../../../../../core/network/api_result.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_profile_repository.dart';
import '../datasource/student_profile_remote_datasource.dart';

class StudentProfileRepositoryImpl implements StudentProfileRepository {
  const StudentProfileRepositoryImpl({
    required StudentProfileRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final StudentProfileRemoteDataSource _remote;

  @override
  Future<ApiResult<StudentProfile?>> fetchProfile() =>
      ApiResult.guard(() async => (await _remote.fetch())?.toEntity());
}
