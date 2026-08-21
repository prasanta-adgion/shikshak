import '../../../../../core/network/api_result.dart';
import '../../domain/entities/teacher_details.dart';
import '../../domain/repositories/single_teacher_repository.dart';
import '../datasource/single_teacher_remote_datasource.dart';

class SingleTeacherRepositoryImpl implements SingleTeacherRepository {
  const SingleTeacherRepositoryImpl({
    required SingleTeacherRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final SingleTeacherRemoteDataSource _remote;

  @override
  Future<ApiResult<TeacherDetails>> fetchTeacher(String teacherId) =>
      ApiResult.guard(() async => (await _remote.fetch(teacherId)).toEntity());
}
