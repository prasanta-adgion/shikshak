import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/constants/api_endpoints.dart';
import 'package:shiksak/core/network/i_api_client.dart';
import 'package:shiksak/core/providers/core_providers.dart';
import 'package:shiksak/features/student/all_teachers/presentation/providers/all_teachers_providers.dart';

/// Serves one teacher per page, exactly as `limit=1` does on the real
/// endpoint: three teachers, three pages, `page` counting up with each call.
class _PagingApiClient implements IApiClient {
  _PagingApiClient({this.totalPages = 3, this.total = 3});

  final int totalPages;
  final int total;

  /// Every `page` the notifier asked for, in order.
  final List<int> requestedPages = [];

  int get requestCount => requestedPages.length;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    expect(path, ApiEndpoints.getAvailableTeacher);

    final page = queryParameters!['page'] as int;
    requestedPages.add(page);

    return <String, dynamic>{
          'success': true,
          'code': 200,
          'message': 'Teachers fetched successfully',
          'data': <String, dynamic>{
            'teachers': <Map<String, dynamic>>[_teacher(page)],
            'pagination': <String, dynamic>{
              'page': page,
              'limit': 1,
              'total': total,
              'totalPages': totalPages,
              'sortOrder': 'desc',
            },
          },
        }
        as T;
  }

  static Map<String, dynamic> _teacher(int page) => <String, dynamic>{
    'user': <String, dynamic>{
      'id': 'teacher-$page',
      'name': 'Teacher $page',
      'email': 'teacher$page@example.com',
      'role': 'teacher',
      'verified': true,
      'phoneNo': null,
      'isLocked': false,
      'isDeleted': false,
      'createdAt': '2026-08-13T10:22:47.380Z',
      'updatedAt': null,
    },
    'profile': null,
    'aboutYou': null,
    'profilePhotoSignedUrl': null,
  };

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The list only reads.');

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The list only reads.');

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The list only reads.');

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The list only reads.');
}

void main() {
  ProviderContainer containerWith(_PagingApiClient client) {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AllTeachersNotifier paging', () {
    test('walks page 1 → 2 → 3 and stops at totalPages', () async {
      final client = _PagingApiClient();
      final container = containerWith(client);
      final notifier = container.read(allTeachersNotifierProvider.notifier);

      await notifier.load();
      expect(client.requestedPages, [1]);
      expect(container.read(allTeachersNotifierProvider).hasMore, isTrue);

      await notifier.loadMore();
      expect(client.requestedPages, [1, 2]);

      await notifier.loadMore();
      expect(client.requestedPages, [1, 2, 3]);

      final state = container.read(allTeachersNotifierProvider);
      // page == totalPages: the list is complete, so nothing more is asked
      // for however far the scroller runs.
      expect(state.pagination.page, 3);
      expect(state.pagination.totalPages, 3);
      expect(state.hasMore, isFalse);
      expect(state.teachers.map((t) => t.name), [
        'Teacher 1',
        'Teacher 2',
        'Teacher 3',
      ]);

      await notifier.loadMore();
      expect(client.requestCount, 3);
    });

    test('pages are appended, not replaced', () async {
      final client = _PagingApiClient();
      final container = containerWith(client);
      final notifier = container.read(allTeachersNotifierProvider.notifier);

      await notifier.load();
      expect(
        container.read(allTeachersNotifierProvider).teachers,
        hasLength(1),
      );

      await notifier.loadMore();
      expect(
        container.read(allTeachersNotifierProvider).teachers,
        hasLength(2),
      );
    });

    test('a single-page result never asks for page 2', () async {
      final client = _PagingApiClient(totalPages: 1, total: 1);
      final container = containerWith(client);
      final notifier = container.read(allTeachersNotifierProvider.notifier);

      await notifier.load();
      expect(container.read(allTeachersNotifierProvider).hasMore, isFalse);

      await notifier.loadMore();
      expect(client.requestedPages, [1]);
    });

    test('a new search restarts at page 1 and drops the old pages', () async {
      final client = _PagingApiClient();
      final container = containerWith(client);
      final notifier = container.read(allTeachersNotifierProvider.notifier);

      await notifier.load();
      await notifier.loadMore();
      expect(client.requestedPages, [1, 2]);

      await notifier.applyQuery(
        container
            .read(allTeachersNotifierProvider)
            .query
            .copyWith(search: 'rahul', page: 4),
      );

      // Page 4 of the old result set means nothing to a new one.
      expect(client.requestedPages.last, 1);
      expect(
        container.read(allTeachersNotifierProvider).teachers,
        hasLength(1),
      );
    });

    test('refresh re-reads page 1 rather than continuing', () async {
      final client = _PagingApiClient();
      final container = containerWith(client);
      final notifier = container.read(allTeachersNotifierProvider.notifier);

      await notifier.load();
      await notifier.loadMore();
      await notifier.refresh();

      expect(client.requestedPages, [1, 2, 1]);
      expect(
        container.read(allTeachersNotifierProvider).teachers,
        hasLength(1),
      );
    });
  });
}
