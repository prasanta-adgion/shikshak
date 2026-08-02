import 'package:flutter/material.dart';

import '../../domain/entities/education.dart';

class EducationFormController {
  EducationFormController({Education? initial})
    : specialization = TextEditingController(
        text: initial?.specialization ?? '',
      ),
      university = TextEditingController(
        text: initial?.universityCollege ?? '',
      ),
      marks = TextEditingController(text: initial?.marksOrGrade ?? ''),
      degree = ValueNotifier<String?>(initial?.degree),
      yearOfPassing = ValueNotifier<int?>(initial?.yearOfPassing),
      isHighest = ValueNotifier<bool>(initial?.isHighestQualification ?? true),
      certificateUrl = ValueNotifier<String?>(initial?.certificateUrl),
      certificateFileName = ValueNotifier<String?>(
        initial?.certificateFileName,
      ),
      certificateLocalPath = ValueNotifier<String?>(
        initial?.certificateLocalPath,
      );

  /// This year back to 1970, newest first. Built once — the list never changes
  /// while the wizard is on screen.
  static final List<int> years = [
    for (var year = DateTime.now().year; year >= 1970; year--) year,
  ];

  final formKey = GlobalKey<FormState>();

  final TextEditingController specialization;
  final TextEditingController university;
  final TextEditingController marks;

  final ValueNotifier<String?> degree;
  final ValueNotifier<int?> yearOfPassing;
  final ValueNotifier<bool> isHighest;

  /// Remote URL of the certificate, and the two fields describing the file
  /// picked on the device. The picker uploads straight away, so the URL is set
  /// moments after the other two.
  final ValueNotifier<String?> certificateUrl;
  final ValueNotifier<String?> certificateFileName;
  final ValueNotifier<String?> certificateLocalPath;

  /// True while that upload is in flight.
  final isUploading = ValueNotifier<bool>(false);

  /// The select fields have no validator of their own, so their errors stay
  /// hidden until the first submit.
  final showErrors = ValueNotifier<bool>(false);

  /// True when nothing has been typed — the teacher has filed what they wanted
  /// and left the form blank.
  bool get isEmpty =>
      degree.value == null &&
      yearOfPassing.value == null &&
      specialization.text.trim().isEmpty &&
      university.text.trim().isEmpty &&
      marks.text.trim().isEmpty;

  bool validate() {
    showErrors.value = true;

    final formValid = formKey.currentState?.validate() ?? false;
    return formValid && degree.value != null && yearOfPassing.value != null;
  }

  Education toEducation() => Education(
    degree: degree.value,
    specialization: specialization.text.trim(),
    universityCollege: university.text.trim(),
    yearOfPassing: yearOfPassing.value,
    marksOrGrade: marks.text.trim(),
    certificateUrl: certificateUrl.value,
    certificateFileName: certificateFileName.value,
    certificateLocalPath: certificateLocalPath.value,
    isHighestQualification: isHighest.value,
  );

  void setFrom(Education education) {
    specialization.text = education.specialization;
    university.text = education.universityCollege;
    marks.text = education.marksOrGrade;
    degree.value = education.degree;
    yearOfPassing.value = education.yearOfPassing;
    isHighest.value = education.isHighestQualification;
    certificateUrl.value = education.certificateUrl;
    certificateFileName.value = education.certificateFileName;
    certificateLocalPath.value = education.certificateLocalPath;
    showErrors.value = false;
  }

  void reset() {
    formKey.currentState?.reset();
    specialization.clear();
    university.clear();
    marks.clear();
    degree.value = null;
    yearOfPassing.value = null;
    isHighest.value = false;
    certificateUrl.value = null;
    certificateFileName.value = null;
    certificateLocalPath.value = null;
    showErrors.value = false;
  }

  void dispose() {
    specialization.dispose();
    university.dispose();
    marks.dispose();
    degree.dispose();
    yearOfPassing.dispose();
    isHighest.dispose();
    certificateUrl.dispose();
    certificateFileName.dispose();
    certificateLocalPath.dispose();
    isUploading.dispose();
    showErrors.dispose();
  }
}
