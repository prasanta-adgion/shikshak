import 'package:equatable/equatable.dart';

import '../../domain/entities/basic_info.dart';
import '../../domain/entities/gender.dart';

class BasicInfoResponseModel extends Equatable {
  final bool? success;
  final int? code;
  final String? message;
  final BasicInfoData? data;

  const BasicInfoResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  factory BasicInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return BasicInfoResponseModel(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? BasicInfoData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class BasicInfoData extends Equatable {
  final BasicInfoProfileModel? profile;

  const BasicInfoData({this.profile});

  factory BasicInfoData.fromJson(Map<String, dynamic> json) {
    return BasicInfoData(
      profile: json['profile'] != null
          ? BasicInfoProfileModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [profile];
}

class BasicInfoProfileModel extends Equatable {
  final String? id;
  final String? userAuthId;
  final String? profilePhotoUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final bool? isProfileComplete;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const BasicInfoProfileModel({
    this.id,
    this.userAuthId,
    this.profilePhotoUrl,
    this.gender,
    this.dateOfBirth,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isProfileComplete,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BasicInfoProfileModel.fromJson(Map<String, dynamic> json) {
    return BasicInfoProfileModel(
      id: json['id'] as String?,
      userAuthId: json['userAuthId'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// The profile as step 1's form takes it.
  BasicInfo toBasicInfo() => BasicInfo(
    profilePhotoUrl: (profilePhotoUrl?.isEmpty ?? true)
        ? null
        : profilePhotoUrl,
    gender: Gender.fromWire(gender),
    dateOfBirth: _parseDate(dateOfBirth),
    addressLine1: addressLine1 ?? '',
    addressLine2: addressLine2 ?? '',
    city: city ?? '',
    state: state ?? '',
    country: country ?? '',
    postalCode: postalCode ?? '',
  );

  /// `2008-08-02T00:00:00.000Z` — a date, not an instant. Read in UTC and
  /// rebuilt as a plain local date, so a west-of-UTC device cannot land on
  /// the day before.
  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;

    final parsed = DateTime.tryParse(value)?.toUtc();
    if (parsed == null) return null;

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  @override
  List<Object?> get props => [
    id,
    userAuthId,
    profilePhotoUrl,
    gender,
    dateOfBirth,
    addressLine1,
    addressLine2,
    city,
    state,
    country,
    postalCode,
    isProfileComplete,
    status,
    createdAt,
    updatedAt,
  ];
}
