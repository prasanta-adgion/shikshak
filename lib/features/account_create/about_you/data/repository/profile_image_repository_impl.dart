import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/i_api_client.dart';
import '../../domain/repositories/profile_image_repository.dart';

class ProfileImageRepositoryImpl implements ProfileImageRepository {
  const ProfileImageRepositoryImpl(this._client);

  final IApiClient _client;

  @override
  Future<ApiResult<String>> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: Uri.file(filePath).pathSegments.last,
        ),
      });
      final json = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );
      final response = ApiResponse<String>.fromJson(json, _urlFromData);
      final url = response.data;

      if (!response.success || url == null || url.isEmpty) {
        return ApiResult.failure(
          ApiException(
            message: response.message,
            type: ApiExceptionType.server,
          ),
        );
      }

      return ApiResult.success(url);
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }

  static String _urlFromData(Object? data) {
    if (data is String) return data;
    if (data is! Map<String, dynamic>) return '';

    return data['url'] as String? ??
        data['profilePhotoUrl'] as String? ??
        data['avatarUrl'] as String? ??
        '';
  }
}
