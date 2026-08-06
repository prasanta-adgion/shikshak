import 'package:equatable/equatable.dart';

import '../../domain/entities/class_mode.dart';
import '../../domain/entities/class_occurrence.dart';
import '../../domain/entities/slot_time.dart';
import 'json_readers.dart';

/// One entry of the calendar response's `occurrences` array — a dated class.
class ClassOccurrenceModel extends Equatable {
  const ClassOccurrenceModel({
    this.slotId,
    this.date,
    this.startTime,
    this.endTime,
    this.title,
    this.description,
    this.subjects = const [],
    this.classes = const [],
    this.mode,
    this.venueName,
    this.venueAddress,
    this.colorTag,
    this.isException,
  });

  final String? slotId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? title;
  final String? description;
  final List<String> subjects;
  final List<String> classes;
  final String? mode;
  final String? venueName;
  final String? venueAddress;
  final String? colorTag;
  final bool? isException;

  factory ClassOccurrenceModel.fromJson(Map<String, dynamic> json) {
    return ClassOccurrenceModel(
      slotId: json['slotId'] as String?,
      date: json['date'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      subjects: readStringList(json['subjects']),
      classes: readStringList(json['classes']),
      mode: json['mode'] as String?,
      venueName: json['venueName'] as String?,
      venueAddress: json['venueAddress'] as String?,
      colorTag: json['colorTag'] as String?,
      isException: json['isException'] as bool?,
    );
  }

  /// Null when the class cannot be placed on the calendar — no readable date
  /// or no readable start time. Both are what "when is this class" means, so
  /// a row missing either is dropped rather than guessed at.
  ClassOccurrence? toEntity() {
    final date = readDate(this.date);
    final start = SlotTime.tryParse(startTime);
    if (date == null || start == null) return null;

    return ClassOccurrence(
      slotId: slotId ?? '',
      date: date,
      title: readTitle(title),
      startTime: start,
      endTime: SlotTime.tryParse(endTime),
      description: description,
      subjects: subjects,
      classes: classes,
      mode: ClassMode.tryParse(mode),
      venueName: venueName,
      venueAddress: venueAddress,
      colorTag: colorTag,
      isException: isException ?? false,
    );
  }

  @override
  List<Object?> get props => [
    slotId,
    date,
    startTime,
    endTime,
    title,
    description,
    subjects,
    classes,
    mode,
    venueName,
    venueAddress,
    colorTag,
    isException,
  ];
}
