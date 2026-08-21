import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/i_api_client.dart';
import '../../domain/params/teacher_query_params.dart';
import '../model/teachers_details_model.dart';

abstract interface class AllTeachersRemoteDataSource {
  /// One page of approved teachers, narrowed by [params].
  Future<TeachersPageModel> fetch(TeacherQueryParams params);
}

class AllTeachersRemoteDataSourceImpl implements AllTeachersRemoteDataSource {
  const AllTeachersRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<TeachersPageModel> fetch(TeacherQueryParams params) async {
    final json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.getAvailableTeacher,
      queryParameters: params.toQueryParameters(),
    );

    final response = TeachersDetailsModel.fromJson(json);
    if (response.success != true) {
      throw ApiException(
        message: response.message ?? 'Could not load teachers.',
        type: ApiExceptionType.server,
      );
    }

    return response.data ?? const TeachersPageModel();
  }
}
