import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/constants/api_endpoints.dart';
import 'package:shiksak/core/network/dio_client.dart';
import 'package:shiksak/core/network/token_refresher.dart';
import 'package:shiksak/core/storage/secure_storage_service.dart';

const _baseUrl = 'https://api.test/';
const _protected = 'api/v1/user/teacher/profile/basic-info';

void main() {
  group('TokenRefresher', () {
    test('stores both new tokens and returns the access token', () async {
      final storage = _FakeStorage(refreshToken: 'refresh-1');
      final adapter = _StubAdapter([_refreshOk('access-2', 'refresh-2')]);

      final token = await _refresherWith(storage, adapter).refresh();

      expect(token, 'access-2');
      expect(storage.token, 'access-2');
      expect(storage.refreshToken, 'refresh-2');
      expect(adapter.requests.single.path, ApiEndpoints.refreshTokenGenerate);
      expect(adapter.requests.single.data, {'refreshToken': 'refresh-1'});
    });

    test('concurrent callers share a single request', () async {
      final storage = _FakeStorage(refreshToken: 'refresh-1');
      final adapter = _StubAdapter([_refreshOk('access-2', 'refresh-2')]);
      final refresher = _refresherWith(storage, adapter);

      final tokens = await Future.wait([
        refresher.refresh(),
        refresher.refresh(),
        refresher.refresh(),
      ]);

      expect(tokens, ['access-2', 'access-2', 'access-2']);
      expect(adapter.requests, hasLength(1));
    });

    test('a later refresh starts a new request', () async {
      final storage = _FakeStorage(refreshToken: 'refresh-1');
      final adapter = _StubAdapter([
        _refreshOk('access-2', 'refresh-2'),
        _refreshOk('access-3', 'refresh-3'),
      ]);
      final refresher = _refresherWith(storage, adapter);

      expect(await refresher.refresh(), 'access-2');
      expect(await refresher.refresh(), 'access-3');
      expect(adapter.requests, hasLength(2));
    });

    test('a rejected refresh token ends the session', () async {
      final storage = _FakeStorage(token: 'access-1', refreshToken: 'spent');
      final adapter = _StubAdapter([
        _json(401, {'success': false, 'message': 'Refresh token expired'}),
      ]);

      expect(await _refresherWith(storage, adapter).refresh(), isNull);
      expect(storage.clearCount, 1);
      expect(storage.refreshToken, isNull);
    });

    // Losing a tunnel is not the same as losing a session — clearing here
    // would log people out for walking into a lift.
    test('an unreachable server leaves the session intact', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final adapter = _StubAdapter([_offline]);

      expect(await _refresherWith(storage, adapter).refresh(), isNull);
      expect(storage.clearCount, 0);
      expect(storage.refreshToken, 'refresh-1');
    });

    test('a 500 leaves the session intact', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final adapter = _StubAdapter([
        _json(500, {'success': false}),
      ]);

      expect(await _refresherWith(storage, adapter).refresh(), isNull);
      expect(storage.clearCount, 0);
      expect(storage.refreshToken, 'refresh-1');
    });

    test('nothing stored to refresh with ends the session', () async {
      final storage = _FakeStorage(token: 'access-1');
      final adapter = _StubAdapter([]);

      expect(await _refresherWith(storage, adapter).refresh(), isNull);
      expect(adapter.requests, isEmpty);
      expect(storage.clearCount, 1);
    });

    test('a response without a token ends the session', () async {
      final storage = _FakeStorage(refreshToken: 'refresh-1');
      final adapter = _StubAdapter([
        _json(200, {'success': true, 'data': <String, dynamic>{}}),
      ]);

      expect(await _refresherWith(storage, adapter).refresh(), isNull);
      expect(storage.clearCount, 1);
    });

    // A payload that omits the refresh token must not wipe the working one.
    test('a response without a refresh token keeps the stored one', () async {
      final storage = _FakeStorage(refreshToken: 'refresh-1');
      final adapter = _StubAdapter([
        _json(200, {
          'success': true,
          'data': {'token': 'access-2'},
        }),
      ]);

      expect(await _refresherWith(storage, adapter).refresh(), 'access-2');
      expect(storage.refreshToken, 'refresh-1');
    });
  });

  group('AuthInterceptor', () {
    test('attaches the stored token to every request', () async {
      final storage = _FakeStorage(token: 'access-1');
      final api = _StubAdapter([
        _json(200, {'success': true}),
      ]);

      await _clientWith(
        storage,
        api,
        _StubAdapter([]),
      ).get<dynamic>(_protected);

      expect(api.requests.single.headers['Authorization'], 'Bearer access-1');
    });

    // The token is never judged locally: only a 401 means expired. A request
    // the server accepts must not cost an extra round trip.
    test('an accepted request never refreshes', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final api = _StubAdapter([
        _json(200, {'success': true}),
      ]);
      final refresh = _StubAdapter([]);

      await _clientWith(storage, api, refresh).get<dynamic>(_protected);

      expect(refresh.requests, isEmpty);
      expect(api.requests, hasLength(1));
    });

    test('a 401 refreshes and retries the request once', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final api = _StubAdapter([
        _json(401, {'success': false, 'message': 'Unauthorized'}),
        _json(200, {'success': true, 'data': 'ok'}),
      ]);
      final refresh = _StubAdapter([_refreshOk('access-2', 'refresh-2')]);

      final body = await _clientWith(
        storage,
        api,
        refresh,
      ).get<Map<String, dynamic>>(_protected);

      expect(body['data'], 'ok');
      expect(api.requests, hasLength(2));
      expect(api.requests.last.headers['Authorization'], 'Bearer access-2');
    });

    test('every request gets its own 401 handling', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final api = _StubAdapter([
        _json(401, {'success': false}),
        _json(200, {'success': true, 'data': 'first'}),
        _json(401, {'success': false}),
        _json(200, {'success': true, 'data': 'second'}),
      ]);
      final refresh = _StubAdapter([
        _refreshOk('access-2', 'refresh-2'),
        _refreshOk('access-3', 'refresh-3'),
      ]);
      final client = _clientWith(storage, api, refresh);

      final first = await client.get<Map<String, dynamic>>(_protected);
      final second = await client.get<Map<String, dynamic>>(
        ApiEndpoints.aboutYou,
      );

      expect(first['data'], 'first');
      expect(second['data'], 'second');
      expect(refresh.requests, hasLength(2));
    });

    // Dio.fetch re-enters the interceptor chain, so the retry marker is the
    // only thing standing between a permanently rejected token and a loop.
    test('a token the server keeps rejecting retries only once', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final api = _StubAdapter([
        _json(401, {'success': false}),
        _json(401, {'success': false}),
      ]);
      final refresh = _StubAdapter([_refreshOk('access-2', 'refresh-2')]);

      await expectLater(
        _clientWith(storage, api, refresh).get<dynamic>(_protected),
        throwsA(anything),
      );

      expect(api.requests, hasLength(2));
      expect(refresh.requests, hasLength(1));
    });

    test('a failed refresh surfaces the original 401', () async {
      final storage = _FakeStorage(token: 'access-1', refreshToken: 'spent');
      final api = _StubAdapter([
        _json(401, {'success': false}),
      ]);
      final refresh = _StubAdapter([
        _json(401, {'success': false}),
      ]);

      await expectLater(
        _clientWith(storage, api, refresh).get<dynamic>(_protected),
        throwsA(anything),
      );

      expect(api.requests, hasLength(1));
      expect(storage.clearCount, 1);
    });

    // A 401 from login means the password was wrong, not that the session
    // lapsed. Refreshing there would be a wasted round trip.
    test('a 401 from a public endpoint is not refreshed', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final api = _StubAdapter([
        _json(401, {'success': false, 'message': 'Invalid credentials'}),
      ]);
      final refresh = _StubAdapter([]);

      await expectLater(
        _clientWith(storage, api, refresh).post<dynamic>(ApiEndpoints.login),
        throwsA(anything),
      );

      expect(refresh.requests, isEmpty);
      expect(api.requests.single.headers['Authorization'], isNull);
    });

    // Sending a FormData consumes its file streams, so replaying the original
    // object would throw instead of retrying. The retry must get a fresh copy.
    test('a multipart upload is replayed with a fresh body', () async {
      final storage = _FakeStorage(
        token: 'access-1',
        refreshToken: 'refresh-1',
      );
      final api = _StubAdapter([
        _json(401, {'success': false}),
        _json(200, {'success': true, 'data': 'uploaded'}),
      ]);
      final refresh = _StubAdapter([_refreshOk('access-2', 'refresh-2')]);

      final body = await _clientWith(storage, api, refresh)
          .post<Map<String, dynamic>>(
            ApiEndpoints.uploadFile,
            data: FormData.fromMap({
              'folder': 'documents',
              'files': MultipartFile.fromBytes(const [
                1,
                2,
                3,
              ], filename: 'note.pdf'),
            }, ListFormat.multi),
          );

      expect(body['data'], 'uploaded');
      expect(api.bodies, hasLength(2));
      expect(api.bodies.first, isA<FormData>());
      expect(api.bodies.last, isA<FormData>());
      expect(identical(api.bodies.first, api.bodies.last), isFalse);
    });
  });
}

// ── helpers ──────────────────────────────────────────────────────────

ResponseBody _json(int statusCode, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody _refreshOk(String token, String refreshToken) => _json(200, {
  'success': true,
  'code': 200,
  'message': 'Token refreshed successfully',
  'data': {
    'user': {
      'id': 'e2fc7ef5-8799-4986-924f-6d40b743f114',
      'name': 'Prasanta',
      'email': 'prasanta.adgion@gmail.com',
      'role': 'teacher',
      'avatarUrl': null,
    },
    'token': token,
    'refreshToken': refreshToken,
  },
});

/// Sentinel for "the request never reached a server".
final _offline = ResponseBody.fromString('', 0);

TokenRefresher _refresherWith(_FakeStorage storage, _StubAdapter adapter) =>
    TokenRefresher(
      baseUrl: _baseUrl,
      storage: storage,
      dio: Dio()..httpClientAdapter = adapter,
    );

DioClient _clientWith(
  _FakeStorage storage,
  _StubAdapter api,
  _StubAdapter refresh,
) => DioClient(
  baseUrl: _baseUrl,
  storage: storage,
  enableLogging: false,
  dio: Dio()..httpClientAdapter = api,
  refresher: _refresherWith(storage, refresh),
);

/// Replays a scripted list of responses, one per request, and records what it
/// was asked for.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this._responses);

  final List<ResponseBody> _responses;
  final List<RequestOptions> requests = [];

  /// Bodies as they were at send time. A retry mutates and reuses the same
  /// [RequestOptions], so `requests` alone cannot tell the two apart.
  final List<Object?> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    bodies.add(options.data);

    if (_responses.isEmpty) {
      throw StateError('unexpected request to ${options.path}');
    }

    final response = _responses.removeAt(0);
    if (identical(response, _offline)) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'stubbed offline',
      );
    }
    return response;
  }

  @override
  void close({bool force = false}) {}
}

class _FakeStorage implements SecureStorageService {
  _FakeStorage({this.token, this.refreshToken});

  String? token;
  String? refreshToken;
  String? role;
  int clearCount = 0;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> saveToken(String value) async => token = value;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveRefreshToken(String value) async => refreshToken = value;

  @override
  Future<String?> getRole() async => role;

  @override
  Future<void> saveRole(String value) async => role = value;

  @override
  Future<void> clear() async {
    clearCount++;
    token = null;
    refreshToken = null;
    role = null;
  }
}
