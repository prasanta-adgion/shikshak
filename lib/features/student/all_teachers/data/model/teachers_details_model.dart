import 'package:equatable/equatable.dart';

import '../../domain/entities/teacher.dart';
import '../../domain/entities/teachers_page.dart';

/// `GET /api/v1/user/student/teachers`.
class TeachersDetailsModel extends Equatable {
  const TeachersDetailsModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  final bool? success;
  final int? code;
  final String? message;
  final TeachersPageModel? data;

  factory TeachersDetailsModel.fromJson(Map<String, dynamic> json) {
    return TeachersDetailsModel(
      success: json['success'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? TeachersPageModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

/// The `data` object: one page of teachers and its counters.
class TeachersPageModel extends Equatable {
  const TeachersPageModel({this.teachers = const [], this.pagination});

  final List<TeacherModel> teachers;
  final PaginationModel? pagination;

  factory TeachersPageModel.fromJson(Map<String, dynamic> json) {
    return TeachersPageModel(
      teachers: json['teachers'] is List
          ? (json['teachers'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TeacherModel.fromJson)
                .toList()
          : const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  TeachersPage toEntity() {
    final teachers = [
      for (final teacher in this.teachers) teacher.toEntity(),
    ];

    return TeachersPage(
      teachers: teachers,
      // No `pagination` block means the whole result arrived in one go, so
      // the scroller must not go asking for a page two that isn't there.
      pagination:
          pagination?.toEntity() ??
          TeacherPageInfo(
            total: teachers.length,
            totalPages: teachers.isEmpty ? 0 : 1,
          ),
    );
  }

  @override
  List<Object?> get props => [teachers, pagination];
}

/// One entry of `data.teachers` — three server rows under one key.
class TeacherModel extends Equatable {
  const TeacherModel({
    this.user,
    this.profile,
    this.aboutYou,
    this.profilePhotoSignedUrl,
  });

  final TeacherUserModel? user;
  final TeacherProfileModel? profile;
  final TeacherAboutModel? aboutYou;

  /// Time-limited URL the app can actually load. Null when no photo was
  /// uploaded.
  final String? profilePhotoSignedUrl;

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      user: json['user'] is Map<String, dynamic>
          ? TeacherUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      profile: json['profile'] is Map<String, dynamic>
          ? TeacherProfileModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
      aboutYou: json['aboutYou'] is Map<String, dynamic>
          ? TeacherAboutModel.fromJson(json['aboutYou'] as Map<String, dynamic>)
          : null,
      profilePhotoSignedUrl: json['profilePhotoSignedUrl'] as String?,
    );
  }

  Teacher toEntity() {
    final user = this.user;
    final profile = this.profile;
    final aboutYou = this.aboutYou;

    return Teacher(
      id: user?.id ?? '',
      name: user?.name ?? '',
      email: user?.email,
      phoneNumber: user?.phoneNo,
      // `profilePhotoUrl` is the private object key, which no image widget
      // can fetch; the signed URL is the one that loads.
      photoUrl: _text(profilePhotoSignedUrl),
      gender: profile?.gender,
      city: profile?.city,
      state: profile?.state,
      country: profile?.country,
      shortBio: _text(aboutYou?.shortBio),
      teachingApproach: _text(aboutYou?.teachingApproach),
      whatMakesYouUnique: _text(aboutYou?.whatMakesYouUnique),
      subjects: aboutYou?.subjectsTaught ?? const [],
      classes: aboutYou?.classesTaught ?? const [],
      languages: aboutYou?.languagesKnown ?? const [],
      isVerified: user?.verified ?? false,
      joinedAt: DateTime.tryParse(user?.createdAt ?? ''),
    );
  }

  static String? _text(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [user, profile, aboutYou, profilePhotoSignedUrl];
}

/// The `user` row — identity as it was set at signup.
class TeacherUserModel extends Equatable {
  const TeacherUserModel({
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

  factory TeacherUserModel.fromJson(Map<String, dynamic> json) {
    return TeacherUserModel(
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

/// The `profile` row — where the teacher is, and how their application went.
class TeacherProfileModel extends Equatable {
  const TeacherProfileModel({
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

  /// Storage key, not a loadable URL — see [TeacherModel.profilePhotoSignedUrl].
  final String? profilePhotoUrl;

  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final bool? isProfileComplete;

  /// `approved` / `pending` / `rejected` — the review verdict.
  final String? status;

  final String? submittedAt;
  final String? reviewedAt;

  /// Internal review comment. Never shown to a student.
  final String? reviewNotes;

  final String? createdAt;
  final String? updatedAt;

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileModel(
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

/// The `aboutYou` row — what the teacher teaches, and how.
class TeacherAboutModel extends Equatable {
  const TeacherAboutModel({
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

  factory TeacherAboutModel.fromJson(Map<String, dynamic> json) {
    return TeacherAboutModel(
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

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];

    return value.whereType<String>().where((e) => e.trim().isNotEmpty).toList();
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

/// The `pagination` block. `sortOrder` is the server echoing the request back.
class PaginationModel extends Equatable {
  const PaginationModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.sortOrder,
  });

  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final String? sortOrder;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      sortOrder: json['sortOrder'] as String?,
    );
  }

  TeacherPageInfo toEntity() => TeacherPageInfo(
    page: page ?? 1,
    limit: limit ?? TeacherPageInfo.defaultPageSize,
    total: total ?? 0,
    totalPages: totalPages ?? 0,
  );

  @override
  List<Object?> get props => [page, limit, total, totalPages, sortOrder];
}
