import '../../../class_schedule/domain/entities/class_mode.dart';
import '../../../class_schedule/domain/entities/schedule_day.dart';
import '../../../class_schedule/domain/entities/slot_time.dart';

class CreateClassParams {
  const CreateClassParams({
    required this.title,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.validFrom,
    required this.mode,
    this.description,
    this.subjects = const [],
    this.classes = const [],
    this.validUntil,
    this.venueName,
    this.venueAddress,
  });

  final String title;

  /// The weekday the slot repeats on.
  final ScheduleDay day;

  final SlotTime startTime;
  final SlotTime endTime;

  /// First date the class runs.
  final DateTime validFrom;

  /// Null means it repeats indefinitely.
  final DateTime? validUntil;

  final ClassMode mode;

  final String? description;
  final List<String> subjects;
  final List<String> classes;

  /// Only meaningful for a mode with a venue — see [ClassMode.hasVenue].
  final String? venueName;
  final String? venueAddress;
}
