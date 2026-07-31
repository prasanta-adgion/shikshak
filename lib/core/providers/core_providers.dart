import 'package:Shikshak/core/media/i_media_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../flavor/app_flavor.dart';
import '../media/media_picker.dart';
import '../network/dio_client.dart';
import '../network/i_api_client.dart';
import '../storage/secure_storage_service.dart';

final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavorConfig.current);

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(
    FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});

/// Photo and document picking, shared by every screen that attaches a file.
final mediaPickerProvider = Provider<IMediaPicker>((ref) => MediaPickerImpl());

final apiClientProvider = Provider<IApiClient>((ref) {
  final flavor = ref.watch(appFlavorProvider);

  return DioClient(
    baseUrl: flavor.baseUrl,
    storage: ref.watch(secureStorageServiceProvider),
    enableLogging: flavor.enableNetworkLogging,
  );
});
