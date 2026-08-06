import '../../../../../../core/network/api_result.dart';
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
      ApiResult.guard(_remote.fetchAll);

  @override
  Future<ApiResult<void>> updateEducation(UpdateEducationParams params) =>
      ApiResult.guard(
        () => _remote.update(
          id: params.id,
          request: EducationRequestModel(education: params.education),
        ),
      );
}
