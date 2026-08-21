import 'teacher_class_slot.dart';

/// One teacher's full profile, as a student sees it: identity, what they
/// teach, and the classes they run.
///
/// Every field below the name is optional — a teacher who filled in nothing
/// else still renders a page that reads as finished.
class TeacherDetails {
  const TeacherDetails({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.gender,
    this.city,
    this.state,
    this.country,
    this.shortBio,
    this.teachingApproach,
    this.whatMakesYouUnique,
    this.subjects = const [],
    this.classes = const [],
    this.languages = const [],
    this.isVerified = false,
    this.joinedAt,
    this.classSlots = const [],
  });

  final String id;

  final String name;
  final String? email;
  final String? phoneNumber;

  /// The signed URL — the private object key the profile carries cannot be
  /// loaded by an image widget.
  final String? photoUrl;

  final String? gender;

  final String? city;
  final String? state;
  final String? country;

  final String? shortBio;
  final String? teachingApproach;
  final String? whatMakesYouUnique;

  final List<String> subjects;
  final List<String> classes;
  final List<String> languages;

  final bool isVerified;

  final DateTime? joinedAt;

  /// Every slot the teacher has filed, running or not.
  final List<TeacherClassSlot> classSlots;

  String get displayName => name.trim().isEmpty ? 'Teacher' : name.trim();

  bool get hasPhoto => _hasText(photoUrl);

  String? get location {
    final parts = [city, state].where(_hasText).cast<String>();
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get subjectsLabel => subjects.isEmpty ? null : subjects.join('  •  ');

  /// Whether the teacher wrote anything about themselves — drives whether the
  /// about block is worth a card at all.
  bool get hasAbout =>
      shortBio != null ||
      teachingApproach != null ||
      whatMakesYouUnique != null;

  /// The slots a student can actually take up. A paused one is the teacher's
  /// own business, not something to offer as a choice.
  List<TeacherClassSlot> get availableClasses => [
    for (final slot in classSlots)
      if (slot.isActive) slot,
  ];

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}
