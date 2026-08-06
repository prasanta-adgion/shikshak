import 'package:equatable/equatable.dart';

import '../../domain/entities/class_mode.dart';
import '../../domain/entities/class_slot.dart';
import '../../domain/entities/schedule_day.dart';
import '../../domain/entities/slot_time.dart';
import 'json_readers.dart';

/// One entry of the calendar response's `slots` array — the recurrence rule.
class ClassSlotModel extends Equatable {
  const ClassSlotModel({
    this.id,
    this.title,
    this.description,
    this.subjects = const [],
    this.classes = const [],
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.validFrom,
    this.validUntil,
    this.mode,
    this.venueName,
    this.venueAddress,
    this.colorTag,
    this.isActive,
  });

  final String? id;
  final String? title;
  final String? description;
  final List<String> subjects;
  final List<String> classes;

  /// 0 (Sunday) – 6 (Saturday). See [ScheduleDay].
  final int? dayOfWeek;

  final String? startTime;
  final String? endTime;
  final String? validFrom;
  final String? validUntil;
  final String? mode;
  final String? venueName;
  final String? venueAddress;
  final String? colorTag;
  final bool? isActive;

  factory ClassSlotModel.fromJson(Map<String, dynamic> json) {
    return ClassSlotModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      subjects: readStringList(json['subjects']),
      classes: readStringList(json['classes']),
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      validFrom: json['validFrom'] as String?,
      validUntil: json['validUntil'] as String?,
      mode: json['mode'] as String?,
      venueName: json['venueName'] as String?,
      venueAddress: json['venueAddress'] as String?,
      colorTag: json['colorTag'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  /// Null when the row cannot be placed on the week grid — no readable day or
  /// no readable start time. Showing such a slot would mean inventing one of
  /// the two things the recurrence is defined by, so it is dropped instead.
  ClassSlot? toEntity() {
    final day = ScheduleDay.fromWire(dayOfWeek);
    final start = SlotTime.tryParse(startTime);
    if (day == null || start == null) return null;

    return ClassSlot(
      id: id ?? '',
      title: readTitle(title),
      day: day,
      startTime: start,
      endTime: SlotTime.tryParse(endTime),
      description: description,
      subjects: subjects,
      classes: classes,
      validFrom: readDate(validFrom),
      validUntil: readDate(validUntil),
      mode: ClassMode.tryParse(mode),
      venueName: venueName,
      venueAddress: venueAddress,
      colorTag: colorTag,
      isActive: isActive ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    subjects,
    classes,
    dayOfWeek,
    startTime,
    endTime,
    validFrom,
    validUntil,
    mode,
    venueName,
    venueAddress,
    colorTag,
    isActive,
  ];
}
