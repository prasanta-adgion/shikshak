import '../../../../../core/network/api_result.dart';
import '../entities/class_slot.dart';
import '../entities/date_range.dart';
import '../entities/schedule_calendar.dart';

abstract interface class ClassScheduleRepository {
  Future<ApiResult<ScheduleCalendar>> fetchWeeklyCalendar(DateRange range);

  Future<ApiResult<List<ClassSlot>>> fetchSlots();
}
