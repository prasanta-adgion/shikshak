import '../../../../../core/network/api_result.dart';
import '../../data/model/experience_response_model.dart';
import '../params/update_experience_params.dart';
import '../repositories/experience_repository.dart';

class GetExperiencesUseCase {
  const GetExperiencesUseCase(this._repository);

  final ExperienceRepository _repository;

  Future<ApiResult<List<ExperienceItem>>> call() =>
      _repository.fetchExperiences();
}

class UpdateExperienceUseCase {
  const UpdateExperienceUseCase(this._repository);

  final ExperienceRepository _repository;

  Future<ApiResult<void>> call(UpdateExperienceParams params) =>
      _repository.updateExperience(params);
}
