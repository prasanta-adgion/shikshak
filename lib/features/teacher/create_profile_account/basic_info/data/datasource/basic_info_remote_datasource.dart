import '../../../../../../core/constants/api_endpoints.dart';
import '../../../../../../core/network/api_exception.dart';
import '../../../../../../core/network/i_api_client.dart';
import '../model/basic_info_response_model.dart';

abstract interface class BasicInfoRemoteDataSource {
  /// The saved profile, or `null` when the teacher has not filed one yet.
  Future<BasicInfoProfileModel?> fetch();
}

class BasicInfoRemoteDataSourceImpl implements BasicInfoRemoteDataSource {
  final IApiClient _client;
  const BasicInfoRemoteDataSourceImpl(this._client);

  @override
  Future<BasicInfoProfileModel?> fetch() async {
    try {
      final json = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.basicInfo,
      );

      final response = BasicInfoResponseModel.fromJson(json);
      if (response.success != true) {
        throw ApiException(
          message: response.message ?? 'Could not load your basic details.',
          type: ApiExceptionType.server,
        );
      }

      return response.data?.profile;
    } on ApiException catch (exception) {
      // A teacher starting the wizard has nothing filed yet; that reads as a
      // blank step, not a failure.
      if (exception.type == ApiExceptionType.notFound) return null;
      rethrow;
    }
  }
}
