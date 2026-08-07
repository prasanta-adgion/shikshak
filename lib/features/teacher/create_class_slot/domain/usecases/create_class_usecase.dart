import '../../../../../core/network/api_result.dart';
import '../params/create_class_params.dart';
import '../repositories/create_class_repository.dart';

class CreateClassUseCase {
  const CreateClassUseCase(this._repository);

  final CreateClassRepository _repository;

  Future<ApiResult<void>> call(CreateClassParams params) =>
      _repository.createClass(params);
}
