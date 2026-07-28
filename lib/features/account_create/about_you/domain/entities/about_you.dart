class AboutYou {
  const AboutYou({
    this.shortBio = '',
    this.teachingApproach = '',
    this.whatMakesYouUnique = '',
    this.subjectsTaught = const [],
    this.classesTaught = const [],
    this.languagesKnown = const [],
  });

  final String shortBio;
  final String teachingApproach;
  final String whatMakesYouUnique;
  final List<String> subjectsTaught;
  final List<String> classesTaught;
  final List<String> languagesKnown;

  AboutYou copyWith({
    String? shortBio,
    String? teachingApproach,
    String? whatMakesYouUnique,
    List<String>? subjectsTaught,
    List<String>? classesTaught,
    List<String>? languagesKnown,
  }) => AboutYou(
    shortBio: shortBio ?? this.shortBio,
    teachingApproach: teachingApproach ?? this.teachingApproach,
    whatMakesYouUnique: whatMakesYouUnique ?? this.whatMakesYouUnique,
    subjectsTaught: subjectsTaught ?? this.subjectsTaught,
    classesTaught: classesTaught ?? this.classesTaught,
    languagesKnown: languagesKnown ?? this.languagesKnown,
  );
}
