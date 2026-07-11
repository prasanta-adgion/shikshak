/// Body sent to the login endpoint.
class LoginRequestModel {
  const LoginRequestModel({
    required this.identifier,
    required this.password,
    required this.role,
  });

  /// Email address or mobile number.
  final String identifier;
  final String password;
  final String role;

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'password': password,
        'role': role,
      };
}
