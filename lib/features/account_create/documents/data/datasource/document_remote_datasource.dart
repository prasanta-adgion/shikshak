import 'dart:io';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/file_uploader/i_file_uploader.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/document_request_model.dart';
import '../model/document_response_model.dart';
import '../model/document_upload_response_model.dart';

abstract interface class DocumentRemoteDataSource {
  Future<List<DocumentItem>> fetchAll();

  Future<DocumentUploadData> upload(String filePath);

  Future<void> update({
    required String id,
    required DocumentRequestModel request,
  });
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final IApiClient _client;
  final IFileUploader _fileUploader;

  const DocumentRemoteDataSourceImpl({
    required IApiClient client,
    required IFileUploader fileUploader,
  }) : _client = client,
       _fileUploader = fileUploader;

  @override
  Future<DocumentUploadData> upload(String filePath) async {
    final result = await _fileUploader.upload(
      ApiEndpoints.uploadFile,
      fileField: 'image',
      files: [File(filePath)],
      fields: const {'folder': 'teacher-documents'},
    );

    return switch (result) {
      ApiSuccess(:final data) => _parseUploadResponse(data),
      ApiFailure(:final exception) => throw exception,
    };
  }

  DocumentUploadData _parseUploadResponse(Map<String, dynamic> json) {
    final response = DocumentUploadResponseModel.fromJson(json);
    final data = response.data;
    if (!response.success || data == null || data.signedUrl.isEmpty) {
      throw ApiException(
        message: response.message,
        type: ApiExceptionType.server,
      );
    }
    return data;
  }

  @override
  Future<List<DocumentItem>> fetchAll() async {
    final json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.documents,
    );

    final response = DocumentResponseModel.fromJson(json);
    if (response.success != true) {
      throw ApiException(
        message: response.message ?? 'Could not load your documents.',
        type: ApiExceptionType.server,
      );
    }

    // A teacher with nothing filed yet is not an error.
    return response.data?.items ?? const [];
  }

  /// `PATCH <documents>/<id>` — the row being changed is named in the path.
  @override
  Future<void> update({
    required String id,
    required DocumentRequestModel request,
  }) async {
    final json = await _client.patch<Map<String, dynamic>>(
      '${ApiEndpoints.documents}/$id',
      data: request.toJson(),
    );

    final response = ApiResponse<void>.fromJson(json, (_) {});
    if (!response.success) {
      throw ApiException(
        message: response.message,
        type: ApiExceptionType.server,
      );
    }
  }
}
