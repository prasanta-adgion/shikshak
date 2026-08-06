import '../../../../../../core/constants/api_endpoints.dart';
import '../../../../../../core/network/api_exception.dart';
import '../../../../../../core/network/api_response.dart';
import '../../../../../../core/network/i_api_client.dart';
import '../model/experience_request_model.dart';
import '../model/experience_response_model.dart';

abstract interface class ExperienceRemoteDataSource {
  Future<List<ExperienceItem>> fetchAll();

  Future<void> update({
    required String id,
    required ExperienceRequestModel request,
  });
}

class ExperienceRemoteDataSourceImpl implements ExperienceRemoteDataSource {
  final IApiClient _client;
  const ExperienceRemoteDataSourceImpl(this._client);

  @override
  Future<List<ExperienceItem>> fetchAll() async {
    final json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.experience,
    );

    final response = ExperienceResponseModel.fromJson(json);
    if (response.success != true) {
      throw ApiException(
        message: response.message ?? 'Could not load your experience.',
        type: ApiExceptionType.server,
      );
    }

    // A teacher with nothing filed yet is not an error.
    return response.data?.items ?? const [];
  }

  /// `PATCH <experience>/<id>` — the row being changed is named in the path.
  @override
  Future<void> update({
    required String id,
    required ExperienceRequestModel request,
  }) async {
    final json = await _client.patch<Map<String, dynamic>>(
      '${ApiEndpoints.experience}/$id',
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
