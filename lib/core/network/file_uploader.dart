import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'api_result.dart';
import 'i_api_client.dart';

/// Turns a file on the device into a URL the API payloads can carry.
///
/// Deliberately its own contract rather than a method on a feature
/// repository: only the parts of a screen that actually attach a file depend
/// on it.
abstract interface class FileUploader {
  /// Uploads the file at [localPath], resolving to its remote URL.
  Future<ApiResult<String>> upload(String localPath, {String? folder});
}

class FileUploaderImpl implements FileUploader {
  const FileUploaderImpl(this._client);

  final IApiClient _client;

  @override
  Future<ApiResult<String>> upload(String localPath, {String? folder}) async {
    try {
      final isFolderUpload = folder != null && folder.isNotEmpty;
      final formData = isFolderUpload
          ? FormData.fromMap({
              // The upload API accepts a list, even with one document.
              'files': [await MultipartFile.fromFile(localPath)],
              'folder': folder,
            })
          : FormData.fromMap({'file': await MultipartFile.fromFile(localPath)});

      final json = await _client.post<Map<String, dynamic>>(
        isFolderUpload ? ApiEndpoints.uploadFile : ApiEndpoints.uploadAvatar,
        data: formData,
      );

      final response = ApiResponse<String>.fromJson(json, (data) {
        final values = data! as Map<String, dynamic>;
        return values[isFolderUpload ? 'signedUrl' : 'url'] as String;
      });
      final url = response.data;

      if (!response.success || url == null || url.isEmpty) {
        return ApiResult.failure(
          ApiException(
            message: response.message,
            type: ApiExceptionType.server,
          ),
        );
      }

      return ApiResult.success(url);
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }
}
