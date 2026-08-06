import '../../../../../../core/network/api_result.dart';
import '../../data/model/education_response_model.dart';
import '../params/update_education_params.dart';

abstract interface class EducationRepository {
  Future<ApiResult<List<EducationItem>>> fetchEducations();

  Future<ApiResult<void>> updateEducation(UpdateEducationParams params);
}
