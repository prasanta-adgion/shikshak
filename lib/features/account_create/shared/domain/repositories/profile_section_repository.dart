import '../../../../../core/network/api_result.dart';

abstract interface class ProfileSectionRepository {
  /// POSTs [body] to [path], or PATCHes it when [isUpdate] is true — that is,
  /// when this section has already been saved once.
  Future<ApiResult<void>> submit({
    required String path,
    required Map<String, dynamic> body,
    required bool isUpdate,
  });
}
