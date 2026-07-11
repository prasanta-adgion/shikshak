import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/dio_client.dart';
import '../network/i_api_client.dart';
import '../storage/secure_storage_service.dart';

/// Core infrastructure providers shared by every feature.

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(
    FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});

final apiClientProvider = Provider<IApiClient>((ref) {
  return DioClient(storage: ref.watch(secureStorageServiceProvider));
});
