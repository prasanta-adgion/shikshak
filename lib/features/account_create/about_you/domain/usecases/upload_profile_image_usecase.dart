import '../../../../../core/network/api_result.dart';
import '../repositories/profile_image_repository.dart';

class UploadProfileImageUseCase {
  const UploadProfileImageUseCase(this._repository);

  final ProfileImageRepository _repository;

  Future<ApiResult<String>> call(String filePath) =>
      _repository.uploadProfileImage(filePath);
}
