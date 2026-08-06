import '../../../../../../core/network/api_result.dart';
import '../repositories/file_upload_repository.dart';

class UploadFileUseCase {
  const UploadFileUseCase(this._repository);

  final FileUploadRepository _repository;

  Future<ApiResult<String>> call({
    required String filePath,
    required String folder,
  }) => _repository.upload(filePath: filePath, folder: folder);
}
