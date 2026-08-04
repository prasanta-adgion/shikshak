import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/document_request_model.dart';
import '../model/document_response_model.dart';

abstract interface class DocumentRemoteDataSource {
  Future<List<DocumentItem>> fetchAll();

  Future<void> update({
    required String id,
    required DocumentRequestModel request,
  });
}

/// The document rows themselves. The file each row points at is uploaded
/// separately, by the shared upload use case, before the row is saved.
class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final IApiClient _client;

  const DocumentRemoteDataSourceImpl(this._client);

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
