import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/constants/api_endpoints.dart';
import 'package:shiksak/core/network/i_api_client.dart';
import 'package:shiksak/core/providers/core_providers.dart';
import 'package:shiksak/features/student/single_teacher_details/domain/entities/teacher_class_slot.dart';
import 'package:shiksak/features/student/single_teacher_details/presentation/providers/single_teacher_providers.dart';

import 'fixtures/single_teacher_response.dart';

const _teacherId = 'b71172f9-b201-4aed-bea1-2151d783cf73';

/// Serves the sample profile, and records the path it was asked for.
class _TeacherApiClient implements IApiClient {
  _TeacherApiClient({Map<String, dynamic>? payload})
    : _payload = payload ?? singleTeacherResponseJson();

  final Map<String, dynamic> _payload;

  final List<String> requestedPaths = [];

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    requestedPaths.add(path);
    return _payload as T;
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The profile only reads.');

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The profile only reads.');

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The profile only reads.');

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The profile only reads.');
}

void main() {
  ProviderContainer containerWith(_TeacherApiClient client) {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SingleTeacherNotifier', () {
    test('asks the teachers endpoint for the id it was given', () async {
      final client = _TeacherApiClient();
      final container = containerWith(client);

      await container
          .read(singleTeacherNotifierProvider.notifier)
          .load(_teacherId);

      expect(client.requestedPaths, [
        ApiEndpoints.availableTeacherById(_teacherId),
      ]);
    });

    test('offers only the running classes, in timetable order', () async {
      final container = containerWith(_TeacherApiClient());
      final notifier = container.read(singleTeacherNotifierProvider.notifier);

      await notifier.load(_teacherId);
      final state = container.read(singleTeacherNotifierProvider);

      // Three slots came back; the paused one is not on offer.
      expect(state.teacher!.classSlots, hasLength(3));
      expect(state.availableClasses.map((slot) => slot.displayTitle), [
        'Board Mathematics — problem solving',
        'Physics doubt clearing',
      ]);
    });

    test('reads the labels a class card shows', () async {
      final container = containerWith(_TeacherApiClient());
      final notifier = container.read(singleTeacherNotifierProvider.notifier);

      await notifier.load(_teacherId);
      final classes = container
          .read(singleTeacherNotifierProvider)
          .availableClasses;

      final inPerson = classes.first;
      expect(inPerson.scheduleLabel, 'Monday  ·  5:30 PM – 7:00 PM');
      expect(inPerson.mode, ClassSlotMode.inPerson);
      expect(inPerson.venueLabel, 'Newtown Study Centre, DB Block, Newtown');
      expect(inPerson.priceLabel, '₹500');

      // No end time, and online — the open-ended, venue-less case.
      final online = classes.last;
      expect(online.scheduleLabel, 'Saturday  ·  9:00 AM');
      expect(online.venueLabel, isEmpty);
      expect(online.priceLabel, 'Free');
    });

    test('picks several classes, and a second tap lets one go', () async {
      final container = containerWith(_TeacherApiClient());
      final notifier = container.read(singleTeacherNotifierProvider.notifier);

      await notifier.load(_teacherId);
      expect(container.read(singleTeacherNotifierProvider).canMessage, isFalse);

      final classes = container
          .read(singleTeacherNotifierProvider)
          .availableClasses;

      notifier.toggleClass(classes.first.id);
      notifier.toggleClass(classes.last.id);
      expect(
        container.read(singleTeacherNotifierProvider).selectedClasses,
        hasLength(2),
      );

      // The other one stays picked: choosing a second class must not have
      // replaced the first.
      notifier.toggleClass(classes.first.id);
      final state = container.read(singleTeacherNotifierProvider);
      expect(state.selectedClasses.map((slot) => slot.id), [classes.last.id]);
      expect(state.canMessage, isTrue);
    });

    test('select all takes every class, and again lets them all go', () async {
      final container = containerWith(_TeacherApiClient());
      final notifier = container.read(singleTeacherNotifierProvider.notifier);

      await notifier.load(_teacherId);
      notifier.toggleSelectAll();

      var state = container.read(singleTeacherNotifierProvider);
      expect(state.isEverythingSelected, isTrue);
      // The paused class is not on offer, so "all" does not reach it.
      expect(state.selectedClasses, hasLength(2));

      notifier.toggleSelectAll();
      state = container.read(singleTeacherNotifierProvider);
      expect(state.selectedClasses, isEmpty);
      expect(state.canMessage, isFalse);
    });

    test('selected classes are listed in timetable order', () async {
      final container = containerWith(_TeacherApiClient());
      final notifier = container.read(singleTeacherNotifierProvider.notifier);

      await notifier.load(_teacherId);
      final classes = container
          .read(singleTeacherNotifierProvider)
          .availableClasses;

      // Tapped Saturday first, then Monday.
      notifier.toggleClass(classes.last.id);
      notifier.toggleClass(classes.first.id);

      expect(
        container
            .read(singleTeacherNotifierProvider)
            .selectedClasses
            .map((slot) => slot.dayLabel),
        ['Monday', 'Saturday'],
      );
    });

    test('a teacher with nothing filled in has no classes to offer', () async {
      final container = containerWith(
        _TeacherApiClient(payload: sparseSingleTeacherResponseJson()),
      );

      await container
          .read(singleTeacherNotifierProvider.notifier)
          .load('5c2f1a77-1d5e-4f2a-8f3b-1c9d0e7a4b21');
      final state = container.read(singleTeacherNotifierProvider);

      expect(state.hasLoaded, isTrue);
      expect(state.teacher!.hasAbout, isFalse);
      expect(state.availableClasses, isEmpty);
      expect(state.canMessage, isFalse);
    });
  });
}
