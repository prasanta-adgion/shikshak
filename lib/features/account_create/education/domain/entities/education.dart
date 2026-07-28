class Education {
  const Education({
    this.degree,
    this.specialization = '',
    this.universityCollege = '',
    this.yearOfPassing,
    this.marksOrGrade = '',
    this.certificateUrl,
    this.certificateFileName,
    this.isHighestQualification = true,
  });

  /// One of [Degrees.all], e.g. `Bachelor of Science`.
  final String? degree;

  final String specialization;
  final String universityCollege;
  final int? yearOfPassing;
  final String marksOrGrade;

  /// Remote URL, set once the picked certificate has been uploaded.
  final String? certificateUrl;

  /// Name of the file chosen on device, shown until that upload happens.
  final String? certificateFileName;

  final bool isHighestQualification;

  Education copyWith({
    String? degree,
    String? specialization,
    String? universityCollege,
    int? yearOfPassing,
    String? marksOrGrade,
    String? certificateUrl,
    String? certificateFileName,
    bool? isHighestQualification,
  }) => Education(
    degree: degree ?? this.degree,
    specialization: specialization ?? this.specialization,
    universityCollege: universityCollege ?? this.universityCollege,
    yearOfPassing: yearOfPassing ?? this.yearOfPassing,
    marksOrGrade: marksOrGrade ?? this.marksOrGrade,
    certificateUrl: certificateUrl ?? this.certificateUrl,
    certificateFileName: certificateFileName ?? this.certificateFileName,
    isHighestQualification:
        isHighestQualification ?? this.isHighestQualification,
  );
}

/// Degrees offered for `degree`, coarse to fine.
abstract final class Degrees {
  static const List<String> all = [
    'High School',
    'Higher Secondary',
    'Diploma',
    'Bachelor of Arts',
    'Bachelor of Science',
    'Bachelor of Commerce',
    'Bachelor of Technology',
    'Bachelor of Education',
    'Master of Arts',
    'Master of Science',
    'Master of Commerce',
    'Master of Technology',
    'Master of Education',
    'M.Phil.',
    'Ph.D.',
    'Other',
  ];
}
