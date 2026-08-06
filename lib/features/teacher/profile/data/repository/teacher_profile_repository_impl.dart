import '../../../../../core/network/api_result.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/teacher_profile_repository.dart';
import '../datasource/teacher_profile_remote_datasource.dart';

class TeacherProfileRepositoryImpl implements TeacherProfileRepository {
  const TeacherProfileRepositoryImpl({
    required TeacherProfileRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final TeacherProfileRemoteDataSource _remote;

  @override
  Future<ApiResult<TeacherProfile?>> fetchProfile() =>
      ApiResult.guard(() async => (await _remote.fetch())?.toEntity());
}
