import 'dart:io';

import '../../../../../../core/constants/api_endpoints.dart';
import '../../../../../../core/network/api_exception.dart';
import '../../../../../../core/network/api_result.dart';
import '../../../../../../core/network/file_uploader/i_file_uploader.dart';
import '../../domain/repositories/file_upload_repository.dart';
import '../model/file_upload_response_model.dart';

/// One transport for every attachment the wizard sends — certificates and
/// documents differ only in the folder they land in.
class FileUploadRepositoryImpl implements FileUploadRepository {
  const FileUploadRepositoryImpl(this._fileUploader);

  final IFileUploader _fileUploader;

  @override
  Future<ApiResult<String>> upload({
    required String filePath,
    required String folder,
  }) async {
    final result = await _fileUploader.upload(
      ApiEndpoints.uploadFile,
      fileField: 'image',
      files: [File(filePath)],
      fields: {'folder': folder},
    );

    return switch (result) {
      ApiFailure(:final exception) => ApiResult.failure(exception),
      ApiSuccess(:final data) => _urlFrom(data),
    };
  }

  ApiResult<String> _urlFrom(Map<String, dynamic> json) {
    final response = FileUploadResponseModel.fromJson(json);
    final url = response.data?.signedUrl ?? '';

    if (!response.success || url.isEmpty) {
      return ApiResult.failure(
        ApiException(message: response.message, type: ApiExceptionType.server),
      );
    }

    return ApiResult.success(url);
  }
}
