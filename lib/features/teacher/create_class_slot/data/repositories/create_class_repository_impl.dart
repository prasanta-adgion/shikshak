import '../../../../../core/network/api_result.dart';
import '../../domain/params/create_class_params.dart';
import '../../domain/repositories/create_class_repository.dart';
import '../datasource/i_create_class_remote_datasource.dart';
import '../mapper/create_class_mapper.dart';

class CreateClassRepositoryImpl implements CreateClassRepository {
  const CreateClassRepositoryImpl({
    required CreateClassRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final CreateClassRemoteDataSource _remote;

  @override
  Future<ApiResult<void>> createClass(CreateClassParams params) =>
      ApiResult.guard(
        () => _remote.createClass(CreateClassMapper.toRequest(params)),
      );
}
