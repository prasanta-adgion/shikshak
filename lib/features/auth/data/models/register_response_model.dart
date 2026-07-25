class RegisterResponseModel {
  const RegisterResponseModel({
    required this.email,
    required this.expiresInSeconds,
  });

  final String email;
  final int expiresInSeconds;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        email: json['email'] as String,
        // Tolerates the value arriving as a JSON number or string.
        expiresInSeconds:
            (json['expiresInSeconds'] as num?)?.toInt() ??
            int.tryParse('${json['expiresInSeconds']}') ??
            0,
      );
}
