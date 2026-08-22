import '../../../../../core/network/api_result.dart';
import '../entities/class_slot.dart';
import '../entities/date_range.dart';
import '../entities/schedule_calendar.dart';

abstract interface class ClassScheduleRepository {
  Future<ApiResult<ScheduleCalendar>> fetchWeeklyCalendar(DateRange range);

  Future<ApiResult<List<ClassSlot>>> fetchSlots();

  /// Pauses or resumes one recurrence. Succeeds with the server's updated
  /// slot, or with `null` when it does not echo one back.
  Future<ApiResult<ClassSlot?>> classActiveInactiveToggle({
    required String slotId,
    required bool isActive,
  });
}
