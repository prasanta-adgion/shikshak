import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/student_profile.dart';

/// `GET /api/v1/user/student/profile`.
class StudentProfileResponseModel extends Equatable {
  const StudentProfileResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  final bool? success;
  final int? code;
  final String? message;
  final StudentProfileData? data;

  factory StudentProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileResponseModel(
      success: json['success'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? StudentProfileData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

/// The `data` object: the auth row and the profile row for one student.
class StudentProfileData extends Equatable {
  const StudentProfileData({this.user, this.profile});

  final StudentUserModel? user;
  final StudentProfileDetailsModel? profile;

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      user: json['user'] is Map<String, dynamic>
          ? StudentUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      profile: json['profile'] is Map<String, dynamic>
          ? StudentProfileDetailsModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  StudentProfile toEntity() {
    final user = this.user;
    final profile = this.profile;

    return StudentProfile(
      user: UserEntity(
        id: user?.id ?? '',
        fullName: user?.name ?? '',
        email: user?.email ?? '',
        mobileNumber: user?.phoneNo,
        // The photo lives on the profile row, not the user row.
        avatarUrl: profile?.avatarUrl,
        role: UserRole.tryParse(user?.role) ?? UserRole.student,
      ),
      coverImageUrl: profile?.coverImageUrl,
      bio: profile?.bio,
      altPhoneNumber: profile?.altPhoneNo,
      dateOfBirth: _parseDate(profile?.dateOfBirth),
      gender: profile?.gender,
      language: profile?.language ?? 'en',
      notificationPrefs: _preferences(profile?.notificationPrefs),
      socialLinks: _links(profile?.socialLinks),
      isProfileComplete: profile?.isProfileComplete ?? false,
      isEmailVerified: user?.verified ?? false,
      joinedAt: _parseDate(user?.createdAt),
      lastSeenAt: _parseDate(profile?.lastSeenAt),
    );
  }

  /// `{"emailUpdates": true, "digest": "weekly"}` → one entry, for
  /// `emailUpdates`. Anything that is not a plain on/off switch is dropped:
  /// this screen can only render the two states.
  static List<NotificationPreference> _preferences(Map<String, dynamic>? json) {
    if (json == null) return const [];

    return [
      for (final MapEntry(:key, :value) in json.entries)
        if (value is bool) NotificationPreference(key: key, isEnabled: value),
    ];
  }

  /// Empty and null values are dropped — a platform with no URL behind it is
  /// not a link the profile should advertise.
  static List<SocialLink> _links(Map<String, dynamic>? json) {
    if (json == null) return const [];

    return [
      for (final MapEntry(:key, :value) in json.entries)
        if (value is String && value.trim().isNotEmpty)
          SocialLink(platform: key, url: value.trim()),
    ];
  }

  @override
  List<Object?> get props => [user, profile];
}

/// The `user` row — identity as it was set at signup.
class StudentUserModel extends Equatable {
  const StudentUserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.verified,
    this.phoneNo,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final bool? verified;
  final String? phoneNo;
  final String? createdAt;

  factory StudentUserModel.fromJson(Map<String, dynamic> json) {
    return StudentUserModel(
      id: json['id'] as String?,
      // `fullName` is what the auth endpoints return for the same person.
      name: json['name'] as String? ?? json['fullName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      verified: json['verified'] as bool?,
      phoneNo: json['phoneNo'] as String? ?? json['mobileNumber'] as String?,
      createdAt: json['createdAt'] as String?,
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
    createdAt,
  ];
}

/// The `profile` row — everything filled in after signup.
class StudentProfileDetailsModel extends Equatable {
  const StudentProfileDetailsModel({
    this.id,
    this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.altPhoneNo,
    this.dateOfBirth,
    this.gender,
    this.language,
    this.notificationPrefs,
    this.socialLinks,
    this.isProfileComplete,
    this.lastSeenAt,
  });

  final String? id;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? altPhoneNo;
  final String? dateOfBirth;
  final String? gender;
  final String? language;
  final Map<String, dynamic>? notificationPrefs;
  final Map<String, dynamic>? socialLinks;
  final bool? isProfileComplete;
  final String? lastSeenAt;

  factory StudentProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileDetailsModel(
      id: json['id'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      bio: json['bio'] as String?,
      altPhoneNo: json['altPhoneNo'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      language: json['language'] as String?,
      notificationPrefs: _map(json['notificationPrefs']),
      socialLinks: _map(json['socialLinks']),
      isProfileComplete: json['isProfileComplete'] as bool?,
      lastSeenAt: json['lastSeenAt'] as String?,
    );
  }

  /// Both JSON columns arrive as `{}` on a fresh profile, and there is no
  /// guarantee a future release will not send `null` or a list instead.
  static Map<String, dynamic>? _map(Object? value) =>
      value is Map<String, dynamic> ? value : null;

  @override
  List<Object?> get props => [
    id,
    avatarUrl,
    coverImageUrl,
    bio,
    altPhoneNo,
    dateOfBirth,
    gender,
    language,
    notificationPrefs,
    socialLinks,
    isProfileComplete,
    lastSeenAt,
  ];
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
