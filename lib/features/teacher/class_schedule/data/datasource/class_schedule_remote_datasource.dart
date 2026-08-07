import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/i_api_client.dart';
import '../../domain/entities/date_range.dart';
import '../model/class_calendar_response_model.dart';
import '../model/class_slot_list_response_model.dart';
import '../model/class_slot_model.dart';

abstract interface class ClassScheduleRemoteDataSource {
  Future<ClassCalendarDataModel> fetchWeeklyCalendar(DateRange range);

  Future<List<ClassSlotModel>> fetchSlots();
}

class ClassScheduleRemoteDataSourceImpl
    implements ClassScheduleRemoteDataSource {
  const ClassScheduleRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<ClassCalendarDataModel> fetchWeeklyCalendar(DateRange range) async {
    try {
      final json = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.getClassSlotsCalendar,
        queryParameters: {'from': range.isoFrom, 'to': range.isoTo},
      );

      final response = ClassCalendarResponseModel.fromJson(json);
      if (response.success != true) {
        throw ApiException(
          message: response.message ?? 'Could not load your schedule.',
          type: ApiExceptionType.server,
        );
      }

      return response.data ?? const ClassCalendarDataModel();
    } on ApiException catch (exception) {
      // A teacher with no slots yet reads as an empty week, not a failure.
      if (exception.type == ApiExceptionType.notFound) {
        return const ClassCalendarDataModel();
      }
      rethrow;
    }
  }

  @override
  Future<List<ClassSlotModel>> fetchSlots() async {
    try {
      final json = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.classSlots,
      );

      final response = ClassSlotListResponseModel.fromJson(json);
      if (response.success != true) {
        throw ApiException(
          message: response.message ?? 'Could not load your class slots.',
          type: ApiExceptionType.server,
        );
      }

      return response.data?.items ?? const [];
    } on ApiException catch (exception) {
      // A teacher who has created none reads as an empty list, not a failure.
      if (exception.type == ApiExceptionType.notFound) return const [];
      rethrow;
    }
  }
}
