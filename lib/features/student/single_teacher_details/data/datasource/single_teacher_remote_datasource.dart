import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/i_api_client.dart';
import '../model/single_teacher_details_model.dart';

abstract interface class SingleTeacherRemoteDataSource {
  /// One teacher by id, with the class slots they run.
  Future<SingleTeacherDataModel> fetch(String teacherId);
}

class SingleTeacherRemoteDataSourceImpl
    implements SingleTeacherRemoteDataSource {
  const SingleTeacherRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<SingleTeacherDataModel> fetch(String teacherId) async {
    final json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.availableTeacherById(teacherId),
    );

    final response = SingleTeachersDetailsModel.fromJson(json);
    if (response.success != true) {
      throw ApiException(
        message: response.message ?? 'Could not load this teacher.',
        type: ApiExceptionType.server,
      );
    }

    final data = response.data;
    if (data == null) {
      // A 200 with no `data` is the shape this endpoint returns for an id
      // that is gone or not approved — an empty profile page would be a
      // worse answer than saying so.
      throw ApiException(
        message: response.message ?? 'This teacher is no longer available.',
        type: ApiExceptionType.server,
      );
    }

    return data;
  }
}
