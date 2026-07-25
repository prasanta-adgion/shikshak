import 'package:Shikshak/core/network/api_response.dart';
import 'package:Shikshak/features/auth/data/models/register_request_model.dart';
import 'package:Shikshak/features/auth/data/models/register_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the signup request/response contract exactly as the backend returns
/// it, so a refactor cannot silently change the wire format.
void main() {
  group('register request body', () {
    test('serialises to the field names the API expects', () {
      const model = RegisterRequestModel(
        fullName: 'Prasanta',
        email: 'prasanta.adgion@gmail.com',
        mobileNumber: '9876543218',
        password: 'Prasanta@123',
        role: 'teacher',
      );

      expect(model.toJson(), {
        'name': 'Prasanta',
        'email': 'prasanta.adgion@gmail.com',
        'phoneNo': '9876543218',
        'password': 'Prasanta@123',
        'role': 'teacher',
      });
    });
  });

  group('register response', () {
    // Verbatim body returned by POST api/v1/auth/signup/request-otp.
    Map<String, dynamic> responseJson() => {
      'success': true,
      'code': 200,
      'message': 'Signup OTP sent successfully',
      'data': {'email': 'prasanta.adgion@gmail.com', 'expiresInSeconds': 600},
    };

    test('envelope decodes, including the code field', () {
      final response = ApiResponse<RegisterResponseModel>.fromJson(
        responseJson(),
        (data) => RegisterResponseModel.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.code, 200);
      expect(response.message, 'Signup OTP sent successfully');
      expect(response.data, isNotNull);
    });

    test('payload parses without leaking into the domain layer', () {
      final model = RegisterResponseModel.fromJson(
        responseJson()['data'] as Map<String, dynamic>,
      );

      expect(model.email, 'prasanta.adgion@gmail.com');
      expect(model.expiresInSeconds, 600);
    });

    test('a failure envelope surfaces the server message', () {
      final response = ApiResponse<RegisterResponseModel>.fromJson(
        {
          'success': false,
          'code': 409,
          'message': 'Email already registered',
          'data': null,
        },
        (data) => RegisterResponseModel.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isFalse);
      expect(response.message, 'Email already registered');
      expect(response.data, isNull);
    });

    test('a malformed body degrades to a readable error, not a TypeError', () {
      // e.g. a proxy/gateway returning its own JSON shape.
      final response = ApiResponse<RegisterResponseModel>.fromJson(
        {'error': 'Bad Gateway'},
        (data) => RegisterResponseModel.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isFalse);
      expect(response.message, isNotEmpty);
      expect(response.data, isNull);
    });
  });
}
