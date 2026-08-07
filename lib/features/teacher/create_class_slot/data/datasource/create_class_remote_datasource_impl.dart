import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/create_class_request.dart';
import 'i_create_class_remote_datasource.dart';

class CreateClassRemoteDataSourceImpl implements CreateClassRemoteDataSource {
  const CreateClassRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<void> createClass(CreateClassRequest request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.classSlots,
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
