import '../../../../../../core/network/api_result.dart';
import '../../data/model/experience_response_model.dart';
import '../params/update_experience_params.dart';

abstract interface class ExperienceRepository {
  Future<ApiResult<List<ExperienceItem>>> fetchExperiences();

  Future<ApiResult<void>> updateExperience(UpdateExperienceParams params);
}
