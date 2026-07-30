import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/repositories/profile_section_repository.dart';
import '../datasource/profile_section_remote_datasource.dart';

class ProfileSectionRepositoryImpl implements ProfileSectionRepository {
  const ProfileSectionRepositoryImpl({
    required ProfileSectionRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final ProfileSectionRemoteDataSource _remote;

  @override
  Future<ApiResult<void>> submit({
    required String path,
    required Map<String, dynamic> body,
    required bool isUpdate,
  }) async {
    print(path);
    try {
      await _remote.submit(path: path, body: body, isUpdate: isUpdate);
      return const ApiResult.success(null);
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }
}
