import 'package:equatable/equatable.dart';

import '../../domain/entities/about_you.dart';

class AboutYouResponseModel extends Equatable {
  final bool? success;
  final int? code;
  final String? message;
  final AboutYouData? data;

  const AboutYouResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  factory AboutYouResponseModel.fromJson(Map<String, dynamic> json) {
    return AboutYouResponseModel(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? AboutYouData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class AboutYouData extends Equatable {
  final AboutYouModel? aboutYou;

  const AboutYouData({this.aboutYou});

  factory AboutYouData.fromJson(Map<String, dynamic> json) {
    return AboutYouData(
      aboutYou: json['aboutYou'] != null
          ? AboutYouModel.fromJson(json['aboutYou'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [aboutYou];
}

class AboutYouModel extends Equatable {
  final String? id;
  final String? teacherProfileId;
  final String? shortBio;
  final String? teachingApproach;
  final String? whatMakesYouUnique;
  final List<String>? subjectsTaught;
  final List<String>? classesTaught;
  final List<String>? languagesKnown;
  final String? createdAt;
  final String? updatedAt;

  const AboutYouModel({
    this.id,
    this.teacherProfileId,
    this.shortBio,
    this.teachingApproach,
    this.whatMakesYouUnique,
    this.subjectsTaught,
    this.classesTaught,
    this.languagesKnown,
    this.createdAt,
    this.updatedAt,
  });

  factory AboutYouModel.fromJson(Map<String, dynamic> json) {
    return AboutYouModel(
      id: json['id'] as String?,
      teacherProfileId: json['teacherProfileId'] as String?,
      shortBio: json['shortBio'] as String?,
      teachingApproach: json['teachingApproach'] as String?,
      whatMakesYouUnique: json['whatMakesYouUnique'] as String?,
      subjectsTaught: _stringList(json['subjectsTaught']),
      classesTaught: _stringList(json['classesTaught']),
      languagesKnown: _stringList(json['languagesKnown']),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// The section as step 2's form takes it.
  AboutYou toAboutYou() => AboutYou(
    shortBio: shortBio ?? '',
    teachingApproach: teachingApproach ?? '',
    whatMakesYouUnique: whatMakesYouUnique ?? '',
    subjectsTaught: subjectsTaught ?? const [],
    classesTaught: classesTaught ?? const [],
    languagesKnown: languagesKnown ?? const [],
  );

  static List<String>? _stringList(Object? value) {
    if (value is! List) return null;
    return value.map((element) => element.toString()).toList();
  }

  @override
  List<Object?> get props => [
    id,
    teacherProfileId,
    shortBio,
    teachingApproach,
    whatMakesYouUnique,
    subjectsTaught,
    classesTaught,
    languagesKnown,
    createdAt,
    updatedAt,
  ];
}
