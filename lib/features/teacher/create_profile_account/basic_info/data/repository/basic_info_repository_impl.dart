import '../../../../../../core/network/api_result.dart';
import '../../domain/entities/basic_info.dart';
import '../../domain/repositories/basic_info_repository.dart';
import '../datasource/basic_info_remote_datasource.dart';

class BasicInfoRepositoryImpl implements BasicInfoRepository {
  const BasicInfoRepositoryImpl({
    required BasicInfoRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final BasicInfoRemoteDataSource _remote;

  @override
  Future<ApiResult<BasicInfo?>> fetchBasicInfo() =>
      ApiResult.guard(() async => (await _remote.fetch())?.toBasicInfo());
}
