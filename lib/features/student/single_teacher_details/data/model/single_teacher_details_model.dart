import 'package:equatable/equatable.dart';

import '../../domain/entities/teacher_class_slot.dart';
import '../../domain/entities/teacher_details.dart';

/// `GET /api/v1/user/student/teachers/{id}` — the discovery list's own
/// endpoint narrowed to one teacher, plus the class slots the list omits.
class SingleTeachersDetailsModel extends Equatable {
  const SingleTeachersDetailsModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  final bool? success;
  final int? code;
  final String? message;
  final SingleTeacherDataModel? data;

  factory SingleTeachersDetailsModel.fromJson(Map<String, dynamic> json) {
    return SingleTeachersDetailsModel(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? SingleTeacherDataModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

/// The four server rows that make up a teacher, under one key.
class SingleTeacherDataModel extends Equatable {
  const SingleTeacherDataModel({
    this.user,
    this.profile,
    this.aboutYou,
    this.classSlots = const [],
    this.profilePhotoSignedUrl,
  });

  final SingleTeacherUserModel? user;
  final SingleTeacherProfileModel? profile;
  final SingleTeacherAboutModel? aboutYou;
  final List<TeacherClassSlotModel> classSlots;

  /// Time-limited URL the app can actually load. Null when no photo was
  /// uploaded.
  final String? profilePhotoSignedUrl;

  factory SingleTeacherDataModel.fromJson(Map<String, dynamic> json) {
    return SingleTeacherDataModel(
      user: json['user'] is Map<String, dynamic>
          ? SingleTeacherUserModel.fromJson(
              json['user'] as Map<String, dynamic>,
            )
          : null,
      profile: json['profile'] is Map<String, dynamic>
          ? SingleTeacherProfileModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
      aboutYou: json['aboutYou'] is Map<String, dynamic>
          ? SingleTeacherAboutModel.fromJson(
              json['aboutYou'] as Map<String, dynamic>,
            )
          : null,
      classSlots: json['classSlots'] is List
          ? (json['classSlots'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TeacherClassSlotModel.fromJson)
                .toList()
          : const [],
      profilePhotoSignedUrl: json['profilePhotoSignedUrl'] as String?,
    );
  }

  TeacherDetails toEntity() {
    final user = this.user;
    final profile = this.profile;
    final aboutYou = this.aboutYou;

    return TeacherDetails(
      id: user?.id ?? '',
      name: user?.name ?? '',
      email: _text(user?.email),
      phoneNumber: _text(user?.phoneNo),
      // `profilePhotoUrl` is the private object key, which no image widget
      // can fetch; the signed URL is the one that loads.
      photoUrl: _text(profilePhotoSignedUrl),
      gender: _text(profile?.gender),
      city: _text(profile?.city),
      state: _text(profile?.state),
      country: _text(profile?.country),
      shortBio: _text(aboutYou?.shortBio),
      teachingApproach: _text(aboutYou?.teachingApproach),
      whatMakesYouUnique: _text(aboutYou?.whatMakesYouUnique),
      subjects: aboutYou?.subjectsTaught ?? const [],
      classes: aboutYou?.classesTaught ?? const [],
      languages: aboutYou?.languagesKnown ?? const [],
      isVerified: user?.verified ?? false,
      joinedAt: DateTime.tryParse(user?.createdAt ?? ''),
      classSlots: _slotEntities(),
    );
  }

  /// Rows without an id are dropped: the page selects a class by id, and a
  /// slot that cannot be selected is not an option to offer. What survives is
  /// ordered the way a timetable reads — by weekday, then by start time.
  List<TeacherClassSlot> _slotEntities() {
    final slots = [
      for (final slot in classSlots)
        if (slot.id != null && slot.id!.isNotEmpty) slot.toEntity(),
    ];

    slots.sort((a, b) {
      final byDay = (a.dayOfWeek ?? 7).compareTo(b.dayOfWeek ?? 7);
      if (byDay != 0) return byDay;
      return (a.startTime ?? '').compareTo(b.startTime ?? '');
    });

    return slots;
  }

  static String? _text(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [
    user,
    profile,
    aboutYou,
    classSlots,
    profilePhotoSignedUrl,
  ];
}

/// The `user` row — identity as it was set at signup.
class SingleTeacherUserModel extends Equatable {
  const SingleTeacherUserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.verified,
    this.phoneNo,
    this.isLocked,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final bool? verified;
  final String? phoneNo;
  final bool? isLocked;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;

  factory SingleTeacherUserModel.fromJson(Map<String, dynamic> json) {
    return SingleTeacherUserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      verified: json['verified'] as bool?,
      phoneNo: json['phoneNo'] as String?,
      isLocked: json['isLocked'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    verified,
    phoneNo,
    isLocked,
    isDeleted,
    createdAt,
    updatedAt,
  ];
}

/// The `profile` row — where the teacher is, and how far through review.
class SingleTeacherProfileModel extends Equatable {
  const SingleTeacherProfileModel({
    this.id,
    this.userAuthId,
    this.profilePhotoUrl,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isProfileComplete,
    this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? userAuthId;
  final String? profilePhotoUrl;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final bool? isProfileComplete;
  final String? status;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewNotes;
  final String? createdAt;
  final String? updatedAt;

  factory SingleTeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return SingleTeacherProfileModel(
      id: json['id'] as String?,
      userAuthId: json['userAuthId'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      gender: json['gender'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool?,
      status: json['status'] as String?,
      submittedAt: json['submittedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      reviewNotes: json['reviewNotes'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userAuthId,
    profilePhotoUrl,
    gender,
    addressLine1,
    addressLine2,
    city,
    state,
    country,
    postalCode,
    isProfileComplete,
    status,
    submittedAt,
    reviewedAt,
    reviewNotes,
    createdAt,
    updatedAt,
  ];
}

/// The `aboutYou` row — what the teacher teaches, and how they describe it.
class SingleTeacherAboutModel extends Equatable {
  const SingleTeacherAboutModel({
    this.id,
    this.teacherProfileId,
    this.shortBio,
    this.teachingApproach,
    this.whatMakesYouUnique,
    this.subjectsTaught = const [],
    this.classesTaught = const [],
    this.languagesKnown = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? teacherProfileId;
  final String? shortBio;
  final String? teachingApproach;
  final String? whatMakesYouUnique;
  final List<String> subjectsTaught;
  final List<String> classesTaught;
  final List<String> languagesKnown;
  final String? createdAt;
  final String? updatedAt;

  factory SingleTeacherAboutModel.fromJson(Map<String, dynamic> json) {
    return SingleTeacherAboutModel(
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

/// One entry of `classSlots` — a recurring class the teacher runs.
class TeacherClassSlotModel extends Equatable {
  const TeacherClassSlotModel({
    this.id,
    this.teacherProfileId,
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
    this.paymentAmount,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? teacherProfileId;
  final String? title;
  final String? description;
  final List<String> subjects;
  final List<String> classes;
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? validFrom;
  final String? validUntil;
  final String? mode;
  final String? venueName;
  final String? venueAddress;
  final String? colorTag;

  /// Sent as a number by some rows and as a decimal string by others, so it
  /// is read loosely and parsed once, in [toEntity].
  final dynamic paymentAmount;

  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  factory TeacherClassSlotModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassSlotModel(
      id: json['id'] as String?,
      teacherProfileId: json['teacherProfileId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      subjects: _stringList(json['subjects']),
      classes: _stringList(json['classes']),
      dayOfWeek: json['dayOfWeek'] as int?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      validFrom: json['validFrom'] as String?,
      validUntil: json['validUntil'] as String?,
      mode: json['mode'] as String?,
      venueName: json['venueName'] as String?,
      venueAddress: json['venueAddress'] as String?,
      colorTag: json['colorTag'] as String?,
      paymentAmount: json['paymentAmount'],
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  TeacherClassSlot toEntity() {
    return TeacherClassSlot(
      id: id ?? '',
      title: title?.trim() ?? '',
      description: _text(description),
      subjects: subjects,
      classes: classes,
      dayOfWeek: dayOfWeek,
      startTime: _text(startTime),
      endTime: _text(endTime),
      mode: ClassSlotMode.fromWire(mode),
      venueName: _text(venueName),
      venueAddress: _text(venueAddress),
      price: paymentAmount == null
          ? null
          : num.tryParse(paymentAmount.toString()),
      // A row that never said drops through as running: the teacher filed it,
      // and only an explicit `false` means paused.
      isActive: isActive ?? true,
    );
  }

  static String? _text(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [
    id,
    teacherProfileId,
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
    paymentAmount,
    isActive,
    createdAt,
    updatedAt,
  ];
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}
