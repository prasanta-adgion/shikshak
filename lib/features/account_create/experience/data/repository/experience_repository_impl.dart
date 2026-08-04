import '../../../../../core/network/api_result.dart';
import '../../domain/params/update_experience_params.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasource/experience_remote_datasource.dart';
import '../model/experience_request_model.dart';
import '../model/experience_response_model.dart';

class ExperienceRepositoryImpl implements ExperienceRepository {
  final ExperienceRemoteDataSource _remote;

  const ExperienceRepositoryImpl({
    required ExperienceRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  @override
  Future<ApiResult<List<ExperienceItem>>> fetchExperiences() =>
      ApiResult.guard(_remote.fetchAll);

  @override
  Future<ApiResult<void>> updateExperience(UpdateExperienceParams params) =>
      ApiResult.guard(
        () => _remote.update(
          id: params.id,
          request: ExperienceRequestModel(
            teachingSubjects: params.teachingSubjects,
            classesTaught: params.classesTaught,
            experience: params.experience,
          ),
        ),
      );
}
