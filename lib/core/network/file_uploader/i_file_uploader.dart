import 'dart:io';

import 'package:Shikshak/core/network/api_result.dart';

abstract interface class IFileUploader {
  Future<ApiResult<String>> upload(
    String endpoint, {
    required String fileField,
    required List<File> files,
    Map<String, String>? fields,
  });
}
