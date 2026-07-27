/// Body sent to the login endpoint.
class LoginRequestModel {
  /// Email address or mobile number.
  final String identifier;
  final String password;

  const LoginRequestModel({required this.identifier, required this.password});

  Map<String, dynamic> toJson() => {'email': identifier, 'password': password};
}
