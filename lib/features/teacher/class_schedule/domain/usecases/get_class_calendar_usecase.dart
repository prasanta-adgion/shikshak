import '../../../../../core/network/api_result.dart';
import '../entities/date_range.dart';
import '../entities/schedule_calendar.dart';
import '../repositories/class_schedule_repository.dart';

//business logic action
class GetClassCalendarUseCase {
  const GetClassCalendarUseCase(this._repository);

  final ClassScheduleRepository _repository;

  Future<ApiResult<ScheduleCalendar>> call(DateRange range) =>
      _repository.fetchWeeklyCalendar(range);
}
