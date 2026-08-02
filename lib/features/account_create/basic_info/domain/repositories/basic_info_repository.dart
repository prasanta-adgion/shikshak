import '../../../../../core/network/api_result.dart';
import '../entities/basic_info.dart';

abstract interface class BasicInfoRepository {
  /// `null` when the teacher has not saved this section yet.
  Future<ApiResult<BasicInfo?>> fetchBasicInfo();
}
