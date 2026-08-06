import '../../../../../../core/constants/api_endpoints.dart';
import '../../../../../../core/network/api_exception.dart';
import '../../../../../../core/network/i_api_client.dart';
import '../model/about_you_response_model.dart';

abstract interface class AboutYouRemoteDataSource {
  /// The saved section, or `null` when the teacher has not filed one yet.
  Future<AboutYouModel?> fetch();
}

class AboutYouRemoteDataSourceImpl implements AboutYouRemoteDataSource {
  final IApiClient _client;
  const AboutYouRemoteDataSourceImpl(this._client);

  @override
  Future<AboutYouModel?> fetch() async {
    try {
      final json = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.aboutYou,
      );

      final response = AboutYouResponseModel.fromJson(json);
      if (response.success != true) {
        throw ApiException(
          message: response.message ?? 'Could not load your about-you details.',
          type: ApiExceptionType.server,
        );
      }

      return response.data?.aboutYou;
    } on ApiException catch (exception) {
      // Nothing filed yet reads as a blank step, not a failure.
      if (exception.type == ApiExceptionType.notFound) return null;
      rethrow;
    }
  }
}
