import '../../../../../core/network/api_result.dart';
import '../entities/about_you.dart';

abstract interface class AboutYouRepository {
  /// `null` when the teacher has not saved this section yet.
  Future<ApiResult<AboutYou?>> fetchAboutYou();
}
