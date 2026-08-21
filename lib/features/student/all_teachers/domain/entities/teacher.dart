class Teacher {
  const Teacher({
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
  });

  final String id;

  final String name;
  final String? email;
  final String? phoneNumber;

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

  bool get hasPhoto => _hasText(photoUrl);

  String? get location {
    final parts = [city, state].where(_hasText).cast<String>();
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get subjectsLabel => subjects.isEmpty ? null : subjects.join('  •  ');

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}
