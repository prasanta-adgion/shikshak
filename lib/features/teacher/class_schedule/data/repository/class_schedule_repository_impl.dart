import '../../../../../core/network/api_result.dart';
import '../../domain/entities/class_slot.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/schedule_calendar.dart';
import '../../domain/repositories/class_schedule_repository.dart';
import '../datasource/class_schedule_remote_datasource.dart';
import '../model/class_slot_model.dart';

class ClassScheduleRepositoryImpl implements ClassScheduleRepository {
  const ClassScheduleRepositoryImpl({
    required ClassScheduleRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final ClassScheduleRemoteDataSource _remote;

  @override
  Future<ApiResult<ScheduleCalendar>> fetchWeeklyCalendar(
    DateRange range,
  ) => ApiResult.guard(() async {
    final data = await _remote.fetchWeeklyCalendar(range);

    // Sorted once here so every consumer — the date strip, the week
    // summary, the day's list — reads the same order without re-sorting.
    final occurrences =
        [
          // Null-aware element: rows the model could not place are dropped.
          for (final model in data.occurrences) ?model.toEntity(),
        ]..sort((a, b) {
          final byDate = a.date.compareTo(b.date);

          return byDate != 0 ? byDate : a.startTime.compareTo(b.startTime);
        });

    return ScheduleCalendar(
      // The server echoes the window it actually served; falling back to the requested one keeps the strip and the data in step if it does not, or sends something unreadable.
      range: data.range?.toEntity() ?? range,
      slots: _sortedSlots(data.slots),
      occurrences: occurrences,
    );
  });

  //fetchSlots() is used to fetch all the class slots for a teacher. It calls the remote data source's fetchSlots() method and sorts the returned list of ClassSlotModel objects by day and start time before returning them as a list of ClassSlot entities.
  @override
  Future<ApiResult<List<ClassSlot>>> fetchSlots() =>
      ApiResult.guard(() async => _sortedSlots(await _remote.fetchSlots()));

  static List<ClassSlot> _sortedSlots(List<ClassSlotModel> models) =>
      [for (final model in models) ?model.toEntity()]..sort((a, b) {
        final byDay = a.day.wireIndex.compareTo(b.day.wireIndex);
        return byDay != 0 ? byDay : a.startTime.compareTo(b.startTime);
      });
}
