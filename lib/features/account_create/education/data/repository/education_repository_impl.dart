import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/params/update_education_params.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasource/education_remote_datasource.dart';
import '../model/education_request_model.dart';
import '../model/education_response_model.dart';

class EducationRepositoryImpl implements EducationRepository {
  const EducationRepositoryImpl({
    required EducationRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final EducationRemoteDataSource _remote;

  @override
  Future<ApiResult<List<EducationItem>>> fetchEducations() =>
      _guard(_remote.fetchAll);

  @override
  Future<ApiResult<void>> updateEducation(UpdateEducationParams params) =>
      _guard(
        () => _remote.update(
          id: params.id,
          request: EducationRequestModel(education: params.education),
        ),
      );

  Future<ApiResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return ApiResult.success(await action());
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }
}
