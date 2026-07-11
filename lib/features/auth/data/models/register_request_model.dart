/// Body sent to the register endpoint. Role-specific fields are optional
/// and omitted from JSON when null.
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
    required this.city,
    this.qualification,
    this.experience,
    this.subjects,
    this.studentClass,
    this.preferredSubjects,
  });

  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String role;
  final String city;
  final String? qualification;
  final String? experience;
  final List<String>? subjects;
  final String? studentClass;
  final List<String>? preferredSubjects;

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
        'password': password,
        'role': role,
        'city': city,
        if (qualification != null) 'qualification': qualification,
        if (experience != null) 'experience': experience,
        if (subjects != null) 'subjects': subjects,
        if (studentClass != null) 'student_class': studentClass,
        if (preferredSubjects != null) 'preferred_subjects': preferredSubjects,
      };
}
