import '../../../../auth/domain/entities/user_entity.dart';
import '../../../create_profile_account/about_you/domain/entities/about_you.dart';
import '../../../create_profile_account/basic_info/domain/entities/basic_info.dart';
import '../../../create_profile_account/education/domain/entities/education.dart';
import '../../../create_profile_account/experience/domain/entities/experience_info.dart';

/// Everything the teacher profile screen renders, in one read-only aggregate.
///
/// Composed from the entities the create-profile wizard already defines rather
/// than redeclaring them: the same server rows back both screens, so a field
/// added for the wizard shows up here for free.
class TeacherProfile {
  const TeacherProfile({
    required this.user,
    required this.status,
    this.basicInfo = const BasicInfo(),
    this.aboutYou = const AboutYou(),
    this.experiences = const [],
    this.educations = const [],
    this.documents = const [],
    this.isProfileComplete = false,
    this.isEmailVerified = false,
    this.phoneNumber,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  final UserEntity user;
  final ProfileReviewStatus status;
  final BasicInfo basicInfo;
  final AboutYou aboutYou;
  final List<ExperienceInfo> experiences;
  final List<Education> educations;
  final List<ProfileDocument> documents;

  final bool isProfileComplete;
  final bool isEmailVerified;

  /// Lives on the user row, not on [basicInfo] — the wizard never collects it.
  final String? phoneNumber;

  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  /// Reviewer's reason, populated when [status] is
  /// [ProfileReviewStatus.rejected].
  final String? reviewNotes;

  /// `Chandur Daulatpur Arambagh 712602, Arambagh, West Bengal, India`.
  /// Empty parts are dropped, so a half-filled address still reads cleanly.
  String get formattedAddress => [
    basicInfo.addressLine1,
    basicInfo.addressLine2,
    basicInfo.city,
    basicInfo.state,
    basicInfo.country,
  ].where((part) => part.trim().isNotEmpty).join(', ');
}

/// Where the profile sits in admin review.
enum ProfileReviewStatus {
  pending('Pending review', 'Your profile is with our team for verification.'),
  approved('Approved', 'Your profile is live and visible to students.'),
  rejected(
    'Needs changes',
    'Please update the highlighted details and resubmit.',
  );

  const ProfileReviewStatus(this.label, this.message);

  final String label;
  final String message;

  /// Reads the server value back. Anything unrecognised — including a profile
  /// that was never submitted — counts as still pending.
  static ProfileReviewStatus fromWire(String? value) =>
      switch (value?.toLowerCase()) {
        'approved' => ProfileReviewStatus.approved,
        'rejected' => ProfileReviewStatus.rejected,
        _ => ProfileReviewStatus.pending,
      };
}

/// A document row as the profile screen shows it.
///
/// Distinct from the wizard's `TeacherDocument`: that one models a file being
/// picked and uploaded, and types its `documentType` against an enum that does
/// not yet cover every value the profile endpoint returns (`aadhaar_card`,
/// `pan_card`, `highest_qualification_certificate`, ...). This one keeps the
/// wire value as-is and humanises it for display, so an unknown type still
/// renders instead of disappearing.
class ProfileDocument {
  const ProfileDocument({
    required this.documentType,
    required this.fileName,
    this.fileUrl,
    this.mimeType,
    this.fileSizeBytes,
    this.isVerified = false,
  });

  final String documentType;
  final String fileName;
  final String? fileUrl;
  final String? mimeType;
  final int? fileSizeBytes;
  final bool isVerified;

  /// `aadhaar_card` → `Aadhaar Card`.
  String get typeLabel => documentType
      .split(RegExp(r'[_\s]+'))
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  /// `95 KB` — display only. Mirrors `TeacherDocument.readableSize`.
  String get readableSize {
    final bytes = fileSizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
