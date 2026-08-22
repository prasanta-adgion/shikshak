import 'dart:io';

import 'package:shiksak/core/network/api_result.dart';

abstract interface class IFileUploader {
  Future<ApiResult<Map<String, dynamic>>> upload(
    String endpoint, {
    required String fileField,
    required List<File> files,
    Map<String, String>? fields,
  });
}
