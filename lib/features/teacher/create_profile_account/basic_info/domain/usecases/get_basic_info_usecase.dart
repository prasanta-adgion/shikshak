import '../../../../../../core/network/api_result.dart';
import '../entities/basic_info.dart';
import '../repositories/basic_info_repository.dart';

class GetBasicInfoUseCase {
  const GetBasicInfoUseCase(this._repository);

  final BasicInfoRepository _repository;

  Future<ApiResult<BasicInfo?>> call() => _repository.fetchBasicInfo();
}
