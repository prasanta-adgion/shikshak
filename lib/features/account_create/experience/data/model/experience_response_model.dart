import 'package:equatable/equatable.dart';

class ExperienceResponseModel extends Equatable {
  final bool? success;
  final int? code;
  final String? message;
  final ExperienceData? data;

  const ExperienceResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  factory ExperienceResponseModel.fromJson(Map<String, dynamic> json) {
    return ExperienceResponseModel(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? ExperienceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class ExperienceData extends Equatable {
  final List<ExperienceItem>? items;

  const ExperienceData({this.items});

  factory ExperienceData.fromJson(Map<String, dynamic> json) {
    return ExperienceData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ExperienceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items?.map((e) => e.toJson()).toList()};
  }

  @override
  List<Object?> get props => [items];
}

class ExperienceItem extends Equatable {
  final String? id;
  final String? teacherProfileId;
  final List<String>? teachingSubjects;
  final List<String>? classesTaught;
  final String? totalTeachingExperience;
  final String? currentJobTitle;
  final String? currentInstitution;
  final String? experienceDetails;
  final bool? isCurrent;
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  const ExperienceItem({
    this.id,
    this.teacherProfileId,
    this.teachingSubjects,
    this.classesTaught,
    this.totalTeachingExperience,
    this.currentJobTitle,
    this.currentInstitution,
    this.experienceDetails,
    this.isCurrent,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    return ExperienceItem(
      id: json['id'] as String?,
      teacherProfileId: json['teacherProfileId'] as String?,
      teachingSubjects: (json['teachingSubjects'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      classesTaught: (json['classesTaught'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      totalTeachingExperience: json['totalTeachingExperience'] as String?,
      currentJobTitle: json['currentJobTitle'] as String?,
      currentInstitution: json['currentInstitution'] as String?,
      experienceDetails: json['experienceDetails'] as String?,
      isCurrent: json['isCurrent'] as bool?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherProfileId': teacherProfileId,
      'teachingSubjects': teachingSubjects,
      'classesTaught': classesTaught,
      'totalTeachingExperience': totalTeachingExperience,
      'currentJobTitle': currentJobTitle,
      'currentInstitution': currentInstitution,
      'experienceDetails': experienceDetails,
      'isCurrent': isCurrent,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    teacherProfileId,
    teachingSubjects,
    classesTaught,
    totalTeachingExperience,
    currentJobTitle,
    currentInstitution,
    experienceDetails,
    isCurrent,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];
}
