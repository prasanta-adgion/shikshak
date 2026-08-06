import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/teacher_profile_response_model.dart';

abstract interface class TeacherProfileRemoteDataSource {
  /// The whole profile, or `null` when the teacher has not started one.
  Future<TeacherProfileData?> fetch();
}

class TeacherProfileRemoteDataSourceImpl
    implements TeacherProfileRemoteDataSource {
  const TeacherProfileRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<TeacherProfileData?> fetch() async {
    try {
      final json = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.getProfile,
      );

      final response = TeacherProfileResponseModel.fromJson(json);
      if (response.success != true) {
        throw ApiException(
          message: response.message ?? 'Could not load your profile.',
          type: ApiExceptionType.server,
        );
      }

      return response.data;
    } on ApiException catch (exception) {
      if (exception.type == ApiExceptionType.notFound) return null;
      rethrow;
    }
  }
}
