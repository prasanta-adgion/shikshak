import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/i_api_client.dart';

/// Contract for the profile-section endpoints.
abstract interface class ProfileSectionRemoteDataSource {
  Future<void> submit({
    required String path,
    required Map<String, dynamic> body,
    required bool isUpdate,
  });
}

/// One transport for all five sections — they differ only in path and body,
/// so a datasource per section would be five copies of this method.
class ProfileSectionRemoteDataSourceImpl
    implements ProfileSectionRemoteDataSource {
  final IApiClient _client;
  const ProfileSectionRemoteDataSourceImpl(this._client);

  @override
  Future<void> submit({
    required String path,
    required Map<String, dynamic> body,
    required bool isUpdate,
  }) async {
    final json = isUpdate
        ? await _client.patch<Map<String, dynamic>>(path, data: body)
        : await _client.post<Map<String, dynamic>>(path, data: body);

    _ensureSuccess(json);
  }

  /// These endpoints reply `{success, message}` with nothing the app needs,
  /// so only the envelope's verdict matters.
  void _ensureSuccess(Map<String, dynamic> json) {
    final response = ApiResponse<void>.fromJson(json, (_) {});
    if (!response.success) {
      throw ApiException(
        message: response.message,
        type: ApiExceptionType.server,
      );
    }
  }
}
