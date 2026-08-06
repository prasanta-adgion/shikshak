import '../../../../../../core/network/api_result.dart';
import '../../data/model/education_response_model.dart';
import '../params/update_education_params.dart';
import '../repositories/education_repository.dart';

class GetEducationsUseCase {
  const GetEducationsUseCase(this._repository);

  final EducationRepository _repository;

  Future<ApiResult<List<EducationItem>>> call() =>
      _repository.fetchEducations();
}

class UpdateEducationUseCase {
  const UpdateEducationUseCase(this._repository);

  final EducationRepository _repository;

  Future<ApiResult<void>> call(UpdateEducationParams params) =>
      _repository.updateEducation(params);
}
