import '../../../../../../core/network/api_result.dart';
import '../../domain/entities/about_you.dart';
import '../../domain/repositories/about_you_repository.dart';
import '../datasource/about_you_remote_datasource.dart';

class AboutYouRepositoryImpl implements AboutYouRepository {
  const AboutYouRepositoryImpl({
    required AboutYouRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final AboutYouRemoteDataSource _remote;

  @override
  Future<ApiResult<AboutYou?>> fetchAboutYou() =>
      ApiResult.guard(() async => (await _remote.fetch())?.toAboutYou());
}
