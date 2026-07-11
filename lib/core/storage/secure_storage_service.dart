import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_keys.dart';

/// Thin, testable wrapper around [FlutterSecureStorage].
///
/// The rest of the app never touches the plugin directly — it depends on
/// this service, which can be faked in tests.
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  // ── Tokens ───────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getToken() => _storage.read(key: StorageKeys.accessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  // ── Role ─────────────────────────────────────────────────────────────────

  Future<void> saveRole(String role) =>
      _storage.write(key: StorageKeys.userRole, value: role);

  Future<String?> getRole() => _storage.read(key: StorageKeys.userRole);

  // ── Session ──────────────────────────────────────────────────────────────

  /// Removes every session-related key. Deliberately deletes known keys
  /// (not `deleteAll`) so unrelated secrets stored later are preserved.
  Future<void> clear() => Future.wait([
        _storage.delete(key: StorageKeys.accessToken),
        _storage.delete(key: StorageKeys.refreshToken),
        _storage.delete(key: StorageKeys.userRole),
      ]);
}
