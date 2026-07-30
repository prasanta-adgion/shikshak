import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/education_request_model.dart';
import '../model/education_response_model.dart';

abstract interface class EducationRemoteDataSource {
  Future<List<EducationItem>> fetchAll();

  Future<void> update({
    required String id,
    required EducationRequestModel request,
  });
}

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final IApiClient _client;
  const EducationRemoteDataSourceImpl(this._client);

  @override
  Future<List<EducationItem>> fetchAll() async {
    final json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.education,
    );

    final response = EducationResponseModel.fromJson(json);
    if (response.success != true) {
      throw ApiException(
        message: response.message ?? 'Could not load your education.',
        type: ApiExceptionType.server,
      );
    }

    // A teacher with nothing filed yet is not an error.
    return response.data?.items ?? const [];
  }

  /// `PATCH <education>/<id>` — the row being changed is named in the path.
  @override
  Future<void> update({
    required String id,
    required EducationRequestModel request,
  }) async {
    final json = await _client.patch<Map<String, dynamic>>(
      '${ApiEndpoints.education}/$id',
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
