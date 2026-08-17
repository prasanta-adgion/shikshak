import '../../../../auth/domain/entities/user_entity.dart';

/// Everything the student profile screen renders, in one read-only aggregate.
///
/// The server splits the same person across two rows — `user` (identity, set
/// at signup) and `profile` (everything filled in later) — and this flattens
/// them, so the screen never has to know which row a field came from.
class StudentProfile {
  const StudentProfile({
    required this.user,
    this.coverImageUrl,
    this.bio,
    this.altPhoneNumber,
    this.dateOfBirth,
    this.gender,
    this.language = 'en',
    this.notificationPrefs = const [],
    this.socialLinks = const [],
    this.isProfileComplete = false,
    this.isEmailVerified = false,
    this.joinedAt,
    this.lastSeenAt,
  });

  final UserEntity user;

  /// Banner behind the avatar. The header falls back to the brand gradient
  /// when it is absent, which is the common case.
  final String? coverImageUrl;

  final String? bio;
  final String? altPhoneNumber;
  final DateTime? dateOfBirth;

  /// Kept as the wire value rather than parsed into an enum: the server is
  /// free to add `non_binary` or `prefer_not_to_say` without this screen
  /// silently dropping the answer. [genderLabel] humanises it for display.
  final String? gender;

  /// ISO 639-1 code — `en`, `hi`, `bn`.
  final String language;

  final List<NotificationPreference> notificationPrefs;
  final List<SocialLink> socialLinks;

  /// The server's own verdict. Trusted when `true`; when `false` the screen
  /// shows [missingFields], which is the more useful answer anyway.
  final bool isProfileComplete;

  final bool isEmailVerified;

  /// From the user row's `createdAt` — "member since".
  final DateTime? joinedAt;

  final DateTime? lastSeenAt;

  /// Lives on the profile row, mirrored onto [user] so avatar widgets take a
  /// [UserEntity] and nothing else.
  String? get avatarUrl => user.avatarUrl;

  /// The number given at signup, as opposed to [altPhoneNumber].
  String? get phoneNumber => user.mobileNumber;

  /// `male` → `Male`, `prefer_not_to_say` → `Prefer not to say`.
  String? get genderLabel => sentenceCase(gender);

  /// `en` → `English`. An unknown code is shown as-is rather than hidden.
  String get languageLabel =>
      _languageNames[language.toLowerCase()] ?? language.toUpperCase();

  /// Whole years since [dateOfBirth]; `null` when it was never given.
  int? get age {
    final dateOfBirth = this.dateOfBirth;
    if (dateOfBirth == null) return null;

    final now = DateTime.now();
    var years = now.year - dateOfBirth.year;
    // Not had the birthday yet this year.
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years < 0 ? null : years;
  }

  /// The details the student has not filled in yet, in the order the
  /// completion card lists them.
  List<StudentProfileField> get missingFields => [
    for (final field in StudentProfileField.values)
      if (!_isFilled(field)) field,
  ];

  int get filledFieldCount =>
      StudentProfileField.values.length - missingFields.length;

  int get totalFieldCount => StudentProfileField.values.length;

  /// `0.0` – `1.0`, for the progress ring.
  double get completion => filledFieldCount / totalFieldCount;

  /// The server flag wins when it is set, so a profile the backend considers
  /// finished never nags about a field this list happens to track.
  bool get isComplete => isProfileComplete || missingFields.isEmpty;

  bool _isFilled(StudentProfileField field) => switch (field) {
    StudentProfileField.photo => _hasText(avatarUrl),
    StudentProfileField.bio => _hasText(bio),
    StudentProfileField.dateOfBirth => dateOfBirth != null,
    StudentProfileField.gender => _hasText(gender),
    StudentProfileField.phone => _hasText(phoneNumber),
    StudentProfileField.emailVerified => isEmailVerified,
  };
}

/// What "a complete profile" means to this screen.
///
/// Deliberately short: these are the details that make a student recognisable
/// to a teacher, not every column the profile row carries.
enum StudentProfileField {
  photo('Profile photo'),
  bio('About you'),
  dateOfBirth('Date of birth'),
  gender('Gender'),
  phone('Phone number'),
  emailVerified('Verified email');

  const StudentProfileField(this.label);

  final String label;
}

/// One `notificationPrefs` entry — `{"emailUpdates": true}`.
class NotificationPreference {
  const NotificationPreference({required this.key, required this.isEnabled});

  final String key;
  final bool isEnabled;

  /// `emailUpdates` → `Email updates`.
  String get label => sentenceCase(key) ?? key;
}

/// One `socialLinks` entry — `{"linkedin": "https://…"}`.
class SocialLink {
  const SocialLink({required this.platform, required this.url});

  final String platform;
  final String url;

  /// `linkedin` → `LinkedIn`. Falls back to sentence case, so a platform the
  /// map below has never heard of still reads properly.
  String get label =>
      _platformNames[platform.toLowerCase()] ?? sentenceCase(platform) ?? platform;

  /// `https://www.linkedin.com/in/seema` → `linkedin.com/in/seema`. The
  /// scheme and `www.` carry no information and cost a lot of chip width.
  String get displayUrl {
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasAuthority) return trimmed;

    final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    final path = uri.path == '/' ? '' : uri.path;
    return '$host$path';
  }
}

/// `alt_phone_no` / `altPhoneNo` → `Alt phone no`.
///
/// Shared by every wire value this feature has to show without a translation
/// table: gender, preference keys, platform names.
String? sentenceCase(String? value) {
  if (value == null) return null;

  final spaced = value
      // camelCase → camel Case, before the separators are normalised.
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])([A-Z])'),
        (match) => ' ${match[1]}',
      )
      .replaceAll(RegExp(r'[_\-\s]+'), ' ')
      .trim();
  if (spaced.isEmpty) return null;

  return '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

/// The languages the app ships in. Anything else falls back to its code.
const Map<String, String> _languageNames = {
  'en': 'English',
  'hi': 'Hindi',
  'bn': 'Bengali',
  'ta': 'Tamil',
  'te': 'Telugu',
  'mr': 'Marathi',
  'gu': 'Gujarati',
  'kn': 'Kannada',
  'ml': 'Malayalam',
  'pa': 'Punjabi',
  'ur': 'Urdu',
  'or': 'Odia',
  'as': 'Assamese',
};

const Map<String, String> _platformNames = {
  'linkedin': 'LinkedIn',
  'github': 'GitHub',
  'youtube': 'YouTube',
  'x': 'X',
  'twitter': 'Twitter',
  'instagram': 'Instagram',
  'facebook': 'Facebook',
  'website': 'Website',
  'portfolio': 'Portfolio',
};
