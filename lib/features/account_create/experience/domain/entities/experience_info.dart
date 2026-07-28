class ExperienceInfo {
  const ExperienceInfo({
    this.totalTeachingExperience,
    this.currentJobTitle = '',
    this.currentInstitution = '',
    this.experienceDetails = '',
    this.isCurrent = true,
    this.startDate,
  });

  /// One of [ExperienceRanges.all], e.g. `5-7 years`.
  final String? totalTeachingExperience;

  final String currentJobTitle;
  final String currentInstitution;
  final String experienceDetails;
  final bool isCurrent;
  final DateTime? startDate;

  ExperienceInfo copyWith({
    String? totalTeachingExperience,
    String? currentJobTitle,
    String? currentInstitution,
    String? experienceDetails,
    bool? isCurrent,
    DateTime? startDate,
  }) => ExperienceInfo(
    totalTeachingExperience:
        totalTeachingExperience ?? this.totalTeachingExperience,
    currentJobTitle: currentJobTitle ?? this.currentJobTitle,
    currentInstitution: currentInstitution ?? this.currentInstitution,
    experienceDetails: experienceDetails ?? this.experienceDetails,
    isCurrent: isCurrent ?? this.isCurrent,
    startDate: startDate ?? this.startDate,
  );
}

/// Bands offered for `totalTeachingExperience`.
abstract final class ExperienceRanges {
  static const List<String> all = [
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5-7 years',
    '7-10 years',
    '10+ years',
  ];
}
