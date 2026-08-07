import 'package:Shikshak/features/teacher/profile/data/model/user_profile_model.dart';
import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/domain/entities/user_role.dart';
import '../../../create_profile_account/about_you/data/model/about_you_response_model.dart';
import '../../../create_profile_account/about_you/domain/entities/about_you.dart';
import '../../../create_profile_account/basic_info/data/model/basic_info_response_model.dart';
import '../../../create_profile_account/basic_info/domain/entities/basic_info.dart';
import '../../../create_profile_account/education/data/model/education_response_model.dart';
import '../../../create_profile_account/experience/data/model/experience_response_model.dart';
import '../../domain/entities/teacher_profile.dart';

class TeacherProfileResponseModel extends Equatable {
  const TeacherProfileResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  final bool? success;
  final int? code;
  final String? message;
  final TeacherProfileData? data;

  factory TeacherProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileResponseModel(
      success: json['success'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? TeacherProfileData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class TeacherProfileData extends Equatable {
  const TeacherProfileData({
    this.user,
    this.profile,
    this.aboutYou,
    this.experience = const [],
    this.education = const [],
    this.documents = const [],
    this.submission,
  });

  final ProfileUserModel? user;
  final BasicInfoProfileModel? profile;
  final AboutYouModel? aboutYou;
  final List<ExperienceItem> experience;
  final List<EducationItem> education;
  final List<ProfileDocumentModel> documents;
  final ProfileSubmissionModel? submission;

  factory TeacherProfileData.fromJson(Map<String, dynamic> json) {
    return TeacherProfileData(
      user: json['user'] is Map<String, dynamic>
          ? ProfileUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      profile: json['profile'] is Map<String, dynamic>
          ? BasicInfoProfileModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
      aboutYou: json['aboutYou'] is Map<String, dynamic>
          ? AboutYouModel.fromJson(json['aboutYou'] as Map<String, dynamic>)
          : null,
      experience: _list(json['experience'], ExperienceItem.fromJson),
      education: _list(json['education'], EducationItem.fromJson),
      documents: _list(json['documents'], ProfileDocumentModel.fromJson),
      submission: json['submission'] is Map<String, dynamic>
          ? ProfileSubmissionModel.fromJson(
              json['submission'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  TeacherProfile toEntity() {
    final user = this.user;
    final submission = this.submission;

    return TeacherProfile(
      user:
          user?.toEntity() ??
          const UserEntity(
            id: '',
            fullName: '',
            email: '',
            role: UserRole.teacher,
          ),
      status: ProfileReviewStatus.fromWire(
        submission?.status ?? profile?.status,
      ),
      basicInfo: profile?.toBasicInfo() ?? const BasicInfo(),
      aboutYou: aboutYou?.toAboutYou() ?? const AboutYou(),
      experiences: [for (final item in experience) item.toExperienceInfo()],
      educations: [for (final item in education) item.toEducation()],
      documents: [for (final item in documents) item.toEntity()],
      isProfileComplete:
          submission?.isProfileComplete ?? profile?.isProfileComplete ?? false,
      isEmailVerified: user?.verified ?? false,
      phoneNumber: user?.phoneNo,
      submittedAt: _parseDate(submission?.submittedAt),
      reviewedAt: _parseDate(submission?.reviewedAt),
      reviewNotes: submission?.reviewNotes,
    );
  }

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [
    user,
    profile,
    aboutYou,
    experience,
    education,
    documents,
    submission,
  ];
}

class ProfileSubmissionModel extends Equatable {
  const ProfileSubmissionModel({
    this.isProfileComplete,
    this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  final bool? isProfileComplete;
  final String? status;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewNotes;

  factory ProfileSubmissionModel.fromJson(Map<String, dynamic> json) {
    return ProfileSubmissionModel(
      isProfileComplete: json['isProfileComplete'] as bool?,
      status: json['status'] as String?,
      submittedAt: json['submittedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      reviewNotes: json['reviewNotes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    isProfileComplete,
    status,
    submittedAt,
    reviewedAt,
    reviewNotes,
  ];
}

class ProfileDocumentModel extends Equatable {
  const ProfileDocumentModel({
    this.id,
    this.documentType,
    this.fileName,
    this.fileUrl,
    this.signedUrl,
    this.mimeType,
    this.fileSizeBytes,
    this.isVerified,
  });

  final String? id;
  final String? documentType;
  final String? fileName;
  final String? fileUrl;

  /// Short-lived download URL. Regenerated per request, so it is preferred
  /// over [fileUrl] — the latter's signature is stamped at upload time and has
  /// usually expired by the time the profile is opened.
  final String? signedUrl;

  final String? mimeType;
  final int? fileSizeBytes;
  final bool? isVerified;

  factory ProfileDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProfileDocumentModel(
      id: json['id'] as String?,
      documentType: json['documentType'] as String?,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      signedUrl: json['signedUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      // Tolerates the size arriving as a JSON number or a string.
      fileSizeBytes:
          (json['fileSizeBytes'] as num?)?.toInt() ??
          int.tryParse('${json['fileSizeBytes']}'),
      isVerified: json['isVerified'] as bool?,
    );
  }

  ProfileDocument toEntity() => ProfileDocument(
    documentType: documentType ?? '',
    fileName: fileName ?? '',
    fileUrl: signedUrl ?? fileUrl,
    mimeType: mimeType,
    fileSizeBytes: fileSizeBytes,
    isVerified: isVerified ?? false,
  );

  @override
  List<Object?> get props => [
    id,
    documentType,
    fileName,
    fileUrl,
    signedUrl,
    mimeType,
    fileSizeBytes,
    isVerified,
  ];
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
