import 'package:equatable/equatable.dart';

import '../../domain/entities/date_range.dart';
import 'class_occurrence_model.dart';
import 'class_slot_model.dart';
import 'json_readers.dart';

/// `GET /api/v1/user/teacher/class-slot/calendar?from=&to=` — the envelope.
class ClassCalendarResponseModel extends Equatable {
  const ClassCalendarResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  final bool? success;
  final int? code;
  final String? message;
  final ClassCalendarDataModel? data;

  factory ClassCalendarResponseModel.fromJson(Map<String, dynamic> json) {
    return ClassCalendarResponseModel(
      success: json['success'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? ClassCalendarDataModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class ClassCalendarDataModel extends Equatable {
  const ClassCalendarDataModel({
    this.range,
    this.slots = const [],
    this.occurrences = const [],
  });

  final DateRangeModel? range;
  final List<ClassSlotModel> slots;
  final List<ClassOccurrenceModel> occurrences;

  factory ClassCalendarDataModel.fromJson(Map<String, dynamic> json) {
    return ClassCalendarDataModel(
      range: json['range'] is Map<String, dynamic>
          ? DateRangeModel.fromJson(json['range'] as Map<String, dynamic>)
          : null,
      slots: _list(json['slots'], ClassSlotModel.fromJson),
      occurrences: _list(json['occurrences'], ClassOccurrenceModel.fromJson),
    );
  }

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [range, slots, occurrences];
}

class DateRangeModel extends Equatable {
  const DateRangeModel({this.from, this.to});

  final String? from;
  final String? to;

  factory DateRangeModel.fromJson(Map<String, dynamic> json) =>
      DateRangeModel(from: json['from'] as String?, to: json['to'] as String?);

  /// Null when either end is unreadable — the caller then keeps the range it
  /// asked for, which is what the strip is already drawn from.
  DateRange? toEntity() {
    final from = readDate(this.from);
    final to = readDate(this.to);
    if (from == null || to == null) return null;
    return DateRange(from: from, to: to);
  }

  @override
  List<Object?> get props => [from, to];
}
