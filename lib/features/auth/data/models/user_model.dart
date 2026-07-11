/// Transport model for a user as returned by the API.
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.role,
    this.city,
    this.qualification,
    this.experience,
    this.subjects,
    this.studentClass,
    this.preferredSubjects,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        mobileNumber: json['mobile_number'] as String,
        role: json['role'] as String,
        city: json['city'] as String?,
        qualification: json['qualification'] as String?,
        experience: json['experience'] as String?,
        subjects: (json['subjects'] as List?)?.cast<String>(),
        studentClass: json['student_class'] as String?,
        preferredSubjects: (json['preferred_subjects'] as List?)?.cast<String>(),
      );

  final String id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String role;
  final String? city;
  final String? qualification;
  final String? experience;
  final List<String>? subjects;
  final String? studentClass;
  final List<String>? preferredSubjects;
}
