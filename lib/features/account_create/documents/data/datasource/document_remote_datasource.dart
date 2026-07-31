import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
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
  const DocumentRemoteDataSourceImpl(this._client);

  @override
  Future<DocumentUploadData> upload(String filePath) async {
    final formData = FormData.fromMap({
      'files': [
        await MultipartFile.fromFile(
          filePath,
          filename: Uri.file(filePath).pathSegments.last,
        ),
      ],
      'folder': 'teacher-documents',
    });

    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.uploadFile,
      data: formData,
    );
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
