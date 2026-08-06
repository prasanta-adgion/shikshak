import 'dart:io';

import '../../../../../../core/constants/api_endpoints.dart';
import '../../../../../../core/network/api_exception.dart';
import '../../../../../../core/network/api_response.dart';
import '../../../../../../core/network/api_result.dart';
import '../../../../../../core/network/file_uploader/i_file_uploader.dart';
import '../../domain/repositories/profile_image_repository.dart';

class ProfileImageRepositoryImpl implements ProfileImageRepository {
  const ProfileImageRepositoryImpl(this._fileUploader);

  final IFileUploader _fileUploader;

  @override
  Future<ApiResult<String>> uploadProfileImage(String filePath) async {
    final result = await _fileUploader.upload(
      ApiEndpoints.uploadAvatar,
      fileField: 'image',
      files: [File(filePath)],
    );

    switch (result) {
      case ApiFailure(:final exception):
        return ApiResult.failure(exception);
      case ApiSuccess(:final data):
        final response = ApiResponse<String>.fromJson(data, _urlFromData);
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
    }
  }

  static String _urlFromData(Object? data) => _findUrl(data) ?? '';

  static String? _findUrl(Object? value) {
    if (value is String) {
      final uri = Uri.tryParse(value);
      return uri != null && uri.hasScheme && uri.host.isNotEmpty ? value : null;
    }
    if (value is List) {
      for (final item in value) {
        final url = _findUrl(item);
        if (url != null) return url;
      }
      return null;
    }
    if (value is Map) {
      for (final nested in value.values) {
        final url = _findUrl(nested);
        if (url != null) return url;
      }
    }
    return null;
  }
}
