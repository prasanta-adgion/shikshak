import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/student_profile_response_model.dart';

abstract interface class StudentProfileRemoteDataSource {
  /// The whole profile, or `null` when the student has no profile row yet.
  Future<StudentProfileData?> fetch();
}

class StudentProfileRemoteDataSourceImpl
    implements StudentProfileRemoteDataSource {
  const StudentProfileRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<StudentProfileData?> fetch() async {
    try {
      final json = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.getStudentProfile,
      );

      final response = StudentProfileResponseModel.fromJson(json);
      if (response.success != true) {
        throw ApiException(
          message: response.message ?? 'Could not load your profile.',
          type: ApiExceptionType.server,
        );
      }

      return response.data;
    } on ApiException catch (exception) {
      // "No profile yet" is an empty screen, not an error banner.
      if (exception.type == ApiExceptionType.notFound) return null;
      rethrow;
    }
  }
}
