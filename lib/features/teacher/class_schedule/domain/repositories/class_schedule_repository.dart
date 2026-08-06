import '../../../../../core/network/api_result.dart';
import '../entities/class_slot.dart';
import '../entities/date_range.dart';
import '../entities/schedule_calendar.dart';

abstract interface class ClassScheduleRepository {
  /// The signed-in teacher's calendar for [range]: their recurring slots plus
  /// the dated classes falling inside the window.
  Future<ApiResult<ScheduleCalendar>> fetchCalendar(DateRange range);

  /// Every recurrence the teacher has created, ordered by day then start
  /// time. Empty when they have created none.
  Future<ApiResult<List<ClassSlot>>> fetchSlots();
}
