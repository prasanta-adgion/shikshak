import '../../domain/entities/signup_otp_challenge.dart';

class RegisterApiResponseModel {
  const RegisterApiResponseModel({
    required this.email,
    required this.expiresInSeconds,
  });

  final String email;
  final int expiresInSeconds;

  factory RegisterApiResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterApiResponseModel(
        email: json['email'] as String,
        // Tolerates the value arriving as a JSON number or string.
        expiresInSeconds:
            (json['expiresInSeconds'] as num?)?.toInt() ??
            int.tryParse('${json['expiresInSeconds']}') ??
            0,
      );

  SignupOtpChallenge toEntity() => SignupOtpChallenge(
    email: email,
    expiresIn: Duration(seconds: expiresInSeconds),
  );
}
