import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../flavor/app_flavor.dart';
import '../network/dio_client.dart';
import '../network/i_api_client.dart';
import '../storage/secure_storage_service.dart';

/// Core infrastructure providers shared by every feature.

/// The active build flavor. This is the only place [AppFlavorConfig] is read,
/// so tests override this provider instead of mutating global state.
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavorConfig.current);

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(
    FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});

final apiClientProvider = Provider<IApiClient>((ref) {
  final flavor = ref.watch(appFlavorProvider);

  return DioClient(
    baseUrl: flavor.baseUrl,
    storage: ref.watch(secureStorageServiceProvider),
    enableLogging: flavor != AppFlavor.prod,
  );
});
