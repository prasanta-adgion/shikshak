/// Body sent to the login endpoint.
class LoginRequestModel {
  /// Email address or mobile number.
  final String identifier;
  final String password;
  final String role;

  const LoginRequestModel({
    required this.identifier,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'password': password,
    'role': role,
  };
}
