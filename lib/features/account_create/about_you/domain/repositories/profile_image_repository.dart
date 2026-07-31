import '../../../../../core/network/api_result.dart';

abstract interface class ProfileImageRepository {
  Future<ApiResult<String>> uploadProfileImage(String filePath);
}
