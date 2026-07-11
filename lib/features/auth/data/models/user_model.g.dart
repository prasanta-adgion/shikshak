// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  mobileNumber: json['mobile_number'] as String,
  role: json['role'] as String,
  city: json['city'] as String?,
  qualification: json['qualification'] as String?,
  experience: json['experience'] as String?,
  subjects: (json['subjects'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  studentClass: json['student_class'] as String?,
  preferredSubjects: (json['preferred_subjects'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'email': instance.email,
      'mobile_number': instance.mobileNumber,
      'role': instance.role,
      'city': instance.city,
      'qualification': instance.qualification,
      'experience': instance.experience,
      'subjects': instance.subjects,
      'student_class': instance.studentClass,
      'preferred_subjects': instance.preferredSubjects,
    };
