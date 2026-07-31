import 'dart:io';

import 'package:Shikshak/core/network/file_uploader/i_file_uploader.dart';
import 'package:dio/dio.dart';

import '../api_exception.dart';
import '../api_response.dart';
import '../api_result.dart';
import '../i_api_client.dart';

class FileUploaderImpl implements IFileUploader {
  final IApiClient _client;
  const FileUploaderImpl(this._client);

  @override
  Future<ApiResult<String>> upload(
    String endpoint, {
    required String fileField,
    required List<File> files,
    Map<String, String>? fields,
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        formData.fields.addAll(fields.entries);
      }

      for (final file in files) {
        formData.files.add(
          MapEntry(
            fileField,
            await MultipartFile.fromFile(
              file.path,
              filename: file.uri.pathSegments.last,
            ),
          ),
        );
      }

      final json = await _client.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
      );

      final response = ApiResponse<String>.fromJson(
        json,
        (data) => (data! as Map<String, dynamic>)['url'] as String,
      );
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
