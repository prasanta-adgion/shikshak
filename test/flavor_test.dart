import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/constants/api_endpoints.dart';
import 'package:shiksak/core/flavor/app_flavor.dart';
import 'package:shiksak/core/network/dio_client.dart';
import 'package:shiksak/core/network/i_api_client.dart';
import 'package:shiksak/core/providers/core_providers.dart';
import 'package:shiksak/core/storage/secure_storage_service.dart';

void main() {
  group('AppFlavor', () {
    // Asserted against the configured value, not a literal: the dev host moves
    // with whoever is running the backend, and that is not a test failure.
    test('dev and staging point at a real host', () {
      for (final flavor in [AppFlavor.dev, AppFlavor.staging]) {
        expect(flavor.hasBaseUrl, isTrue, reason: '${flavor.label} baseUrl');
        expect(Uri.parse(flavor.baseUrl).hasScheme, isTrue);
        expect(Uri.parse(flavor.baseUrl).host, isNotEmpty);
      }
    });

    test('prod has no host provisioned yet', () {
      expect(AppFlavor.prod.baseUrl, isEmpty);
      expect(AppFlavor.prod.hasBaseUrl, isFalse);
    });

    test('every flavor has a label', () {
      expect(AppFlavor.dev.label, 'Dev');
      expect(AppFlavor.staging.label, 'Staging');
      expect(AppFlavor.prod.label, 'Prod');
    });
  });

  group('AppFlavorConfig', () {
    // Restore the default so flavor state cannot leak between test files.
    tearDown(() => AppFlavorConfig.set(AppFlavor.prod));

    test('defaults to prod when no entrypoint has set it', () {
      expect(AppFlavorConfig.current, AppFlavor.prod);
      expect(AppFlavorConfig.isProd, isTrue);
    });

    test('set fixes the flavor and its derived config', () {
      AppFlavorConfig.set(AppFlavor.dev);

      expect(AppFlavorConfig.current, AppFlavor.dev);
      expect(AppFlavorConfig.isProd, isFalse);
      expect(AppFlavorConfig.baseUrl, AppFlavor.dev.baseUrl);
      expect(AppFlavorConfig.enableNetworkLogging, isTrue);

      AppFlavorConfig.set(AppFlavor.staging);

      expect(AppFlavorConfig.current, AppFlavor.staging);
      expect(AppFlavorConfig.baseUrl, AppFlavor.staging.baseUrl);
      expect(AppFlavorConfig.enableNetworkLogging, isTrue);
    });

    test('network logging is off in production', () {
      AppFlavorConfig.set(AppFlavor.prod);
      expect(AppFlavorConfig.enableNetworkLogging, isFalse);
    });
  });

  group('apiClientProvider', () {
    test('builds a client from the overridden flavor', () {
      final container = ProviderContainer(
        overrides: [appFlavorProvider.overrideWithValue(AppFlavor.dev)],
      );
      addTearDown(container.dispose);

      expect(container.read(apiClientProvider), isA<DioClient>());
      expect(container.read(apiClientProvider), isA<IApiClient>());
    });

    test('an unprovisioned flavor fails loudly instead of building', () {
      final container = ProviderContainer(
        overrides: [appFlavorProvider.overrideWithValue(AppFlavor.prod)],
      );
      addTearDown(container.dispose);

      // Guards against a build silently issuing relative requests when the
      // environment's baseUrl has not been filled in yet. Riverpod wraps the
      // DioClient assertion, so match on the message rather than the type.
      expect(
        () => container.read(apiClientProvider),
        throwsA(
          predicate(
            (Object e) => e.toString().contains('empty baseUrl'),
            'reports the empty baseUrl',
          ),
        ),
      );
    });
  });

  group('base URL / endpoint joining', () {
    // Dio concatenates baseUrl and path verbatim. A host with no trailing
    // slash plus a path with no leading slash yields ".../:5001api/v1/..." —
    // a FormatException on every request. DioClient normalises the base so
    // either endpoint style is safe; this pins that down.
    const storage = SecureStorageService(FlutterSecureStorage());

    Dio dioFor(String baseUrl) {
      final dio = Dio();
      DioClient(baseUrl: baseUrl, storage: storage, dio: dio);
      return dio;
    }

    for (final host in [
      'http://192.168.1.12:5001',
      'http://192.168.1.12:5001/',
    ]) {
      for (final path in ['api/v1/auth/login', '/api/v1/auth/login']) {
        test('host "$host" + path "$path" resolves correctly', () {
          final uri = RequestOptions(
            baseUrl: dioFor(host).options.baseUrl,
            path: path,
          ).uri;

          expect(uri.toString(), 'http://192.168.1.12:5001/api/v1/auth/login');
          expect(uri.port, 5001);
        });
      }
    }

    test('the dev flavor resolves the real login endpoint', () {
      final configured = Uri.parse(AppFlavor.dev.baseUrl);

      final uri = RequestOptions(
        baseUrl: dioFor(AppFlavor.dev.baseUrl).options.baseUrl,
        path: ApiEndpoints.login,
      ).uri;

      // Whatever host dev is pointed at, the path must join onto it cleanly.
      expect(uri.host, configured.host);
      expect(uri.port, configured.port);
      expect(uri.path, '/api/v1/auth/login');
    });
  });
}
