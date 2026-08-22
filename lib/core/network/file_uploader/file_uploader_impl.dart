import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shiksak/core/network/file_uploader/i_file_uploader.dart';

import '../api_exception.dart';
import '../api_result.dart';
import '../i_api_client.dart';

class FileUploaderImpl implements IFileUploader {
  final IApiClient _client;
  const FileUploaderImpl(this._client);

  @override
  Future<ApiResult<Map<String, dynamic>>> upload(
    String endpoint, {
    required String fileField,
    required List<File> files,
    Map<String, String>? fields,
  }) async {
    try {
      final multipartFiles = await Future.wait(
        files.map(
          (file) => MultipartFile.fromFile(
            file.path,
            filename: file.uri.pathSegments.last,
          ),
        ),
      );

      // Match the upload API contract exactly:
      // { "files": [MultipartFile, ...], "folder": "..." }.
      // ListFormat.multi keeps every part named `files` rather than `files[]`.
      final formData = FormData.fromMap({
        ...?fields,
        fileField: multipartFiles,
      }, ListFormat.multi);

      final response = await _client.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
      );

      return ApiResult.success(response);
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }
}
