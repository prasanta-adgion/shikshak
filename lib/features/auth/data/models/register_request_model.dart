/// Body sent to the register endpoint. Role-specific fields are optional
/// and omitted from JSON when null.
class RegisterRequestModel {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String role;
  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'name': fullName,
    'email': email,
    'phoneNo': mobileNumber,
    'password': password,
    'role': role,
  };
}
