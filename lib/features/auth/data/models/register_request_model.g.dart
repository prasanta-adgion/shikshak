// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => _RegisterRequestModel(
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  mobileNumber: json['mobile_number'] as String,
  password: json['password'] as String,
  role: json['role'] as String,
  city: json['city'] as String,
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

Map<String, dynamic> _$RegisterRequestModelToJson(
  _RegisterRequestModel instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'email': instance.email,
  'mobile_number': instance.mobileNumber,
  'password': instance.password,
  'role': instance.role,
  'city': instance.city,
  'qualification': ?instance.qualification,
  'experience': ?instance.experience,
  'subjects': ?instance.subjects,
  'student_class': ?instance.studentClass,
  'preferred_subjects': ?instance.preferredSubjects,
};
