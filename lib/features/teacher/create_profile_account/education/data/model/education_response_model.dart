import 'package:equatable/equatable.dart';

import '../../domain/entities/education.dart';

class EducationResponseModel extends Equatable {
  final bool? success;
  final int? code;
  final String? message;
  final EducationData? data;

  const EducationResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  factory EducationResponseModel.fromJson(Map<String, dynamic> json) {
    return EducationResponseModel(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? EducationData.fromJson(json['data'] as Map<String, dynamic>)
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

class EducationData extends Equatable {
  final List<EducationItem>? items;

  const EducationData({this.items});

  factory EducationData.fromJson(Map<String, dynamic> json) {
    return EducationData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => EducationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items?.map((e) => e.toJson()).toList()};
  }

  @override
  List<Object?> get props => [items];
}

class EducationItem extends Equatable {
  final String? id;
  final String? teacherProfileId;
  final String? degree;
  final String? specialization;
  final String? universityCollege;
  final int? yearOfPassing;
  final String? marksOrGrade;
  final String? certificateUrl;
  final bool? isHighestQualification;
  final String? createdAt;
  final String? updatedAt;

  const EducationItem({
    this.id,
    this.teacherProfileId,
    this.degree,
    this.specialization,
    this.universityCollege,
    this.yearOfPassing,
    this.marksOrGrade,
    this.certificateUrl,
    this.isHighestQualification,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id'] as String?,
      teacherProfileId: json['teacherProfileId'] as String?,
      degree: json['degree'] as String?,
      specialization: json['specialization'] as String?,
      universityCollege: json['universityCollege'] as String?,
      yearOfPassing: json['yearOfPassing'] as int?,
      marksOrGrade: json['marksOrGrade'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      isHighestQualification: json['isHighestQualification'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// The row as the edit form takes it.
  Education toEducation() => Education(
    degree: degree,
    specialization: specialization ?? '',
    universityCollege: universityCollege ?? '',
    yearOfPassing: yearOfPassing,
    marksOrGrade: marksOrGrade ?? '',
    certificateUrl: certificateUrl,
    isHighestQualification: isHighestQualification ?? true,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherProfileId': teacherProfileId,
      'degree': degree,
      'specialization': specialization,
      'universityCollege': universityCollege,
      'yearOfPassing': yearOfPassing,
      'marksOrGrade': marksOrGrade,
      'certificateUrl': certificateUrl,
      'isHighestQualification': isHighestQualification,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    teacherProfileId,
    degree,
    specialization,
    universityCollege,
    yearOfPassing,
    marksOrGrade,
    certificateUrl,
    isHighestQualification,
    createdAt,
    updatedAt,
  ];
}
