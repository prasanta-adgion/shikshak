import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../flavor/app_flavor.dart';
import '../media/media_picker.dart';
import '../network/dio_client.dart';
import '../network/file_uploader.dart';
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

/// Photo and document picking, shared by every screen that attaches a file.
final mediaPickerProvider = Provider<MediaPicker>((ref) => MediaPickerImpl());

final fileUploaderProvider = Provider<FileUploader>((ref) {
  return FileUploaderImpl(ref.watch(apiClientProvider));
});

final apiClientProvider = Provider<IApiClient>((ref) {
  final flavor = ref.watch(appFlavorProvider);

  return DioClient(
    baseUrl: flavor.baseUrl,
    storage: ref.watch(secureStorageServiceProvider),
    enableLogging: flavor.enableNetworkLogging,
  );
});
