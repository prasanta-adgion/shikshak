import '../../../../../core/network/api_result.dart';
import '../../domain/entities/teachers_page.dart';
import '../../domain/params/teacher_query_params.dart';
import '../../domain/repositories/all_teachers_repository.dart';
import '../datasource/all_teachers_remote_datasource.dart';

class AllTeachersRepositoryImpl implements AllTeachersRepository {
  final AllTeachersRemoteDataSource _remote;

  const AllTeachersRepositoryImpl({
    required AllTeachersRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  @override
  Future<ApiResult<TeachersPage>> fetchTeachers(TeacherQueryParams params) =>
      ApiResult.guard(() async => (await _remote.fetch(params)).toEntity());
}
