import '../../domain/entities/education.dart';

class EducationRequestModel {
  const EducationRequestModel({required this.education});

  final Education education;

  Map<String, dynamic> toJson() => {
    'degree': education.degree ?? '',
    'specialization': education.specialization,
    'universityCollege': education.universityCollege,
    'yearOfPassing': education.yearOfPassing ?? '',
    'marksOrGrade': education.marksOrGrade,
    'certificateUrl': education.certificateUrl ?? '',
    'isHighestQualification': education.isHighestQualification,
  };
}
