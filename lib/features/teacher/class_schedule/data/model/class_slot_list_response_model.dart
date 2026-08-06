import 'package:equatable/equatable.dart';

import 'class_slot_model.dart';

/// `GET /api/v1/user/teacher/class-slot` — every recurrence the teacher has
/// created, with no date window applied.
///
/// Distinct from the calendar envelope: this one carries the rules only, so
/// there is no `range` and no expansion into dated classes.
class ClassSlotListResponseModel extends Equatable {
  const ClassSlotListResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  final bool? success;
  final int? code;
  final String? message;
  final ClassSlotListModel? data;

  factory ClassSlotListResponseModel.fromJson(Map<String, dynamic> json) {
    return ClassSlotListResponseModel(
      success: json['success'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? ClassSlotListModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class ClassSlotListModel extends Equatable {
  const ClassSlotListModel({this.items = const []});

  final List<ClassSlotModel> items;

  factory ClassSlotListModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return ClassSlotListModel(
      items: items is! List
          ? const []
          : items
                .whereType<Map<String, dynamic>>()
                .map(ClassSlotModel.fromJson)
                .toList(growable: false),
    );
  }

  @override
  List<Object?> get props => [items];
}
