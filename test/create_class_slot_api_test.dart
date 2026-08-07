import 'package:Shikshak/core/constants/api_endpoints.dart';
import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/network/api_result.dart';
import 'package:Shikshak/core/network/i_api_client.dart';
import 'package:Shikshak/core/providers/core_providers.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/class_mode.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/schedule_day.dart';
import 'package:Shikshak/features/teacher/class_schedule/domain/entities/slot_time.dart';
import 'package:Shikshak/features/teacher/create_class_slot/data/datasource/create_class_remote_datasource_impl.dart';
import 'package:Shikshak/features/teacher/create_class_slot/data/datasource/i_create_class_remote_datasource.dart';
import 'package:Shikshak/features/teacher/create_class_slot/data/mapper/create_class_mapper.dart';
import 'package:Shikshak/features/teacher/create_class_slot/data/repositories/create_class_repository_impl.dart';
import 'package:Shikshak/features/teacher/create_class_slot/domain/params/create_class_params.dart';
import 'package:Shikshak/features/teacher/create_class_slot/presentation/controller/class_slot_form_controller.dart';
import 'package:Shikshak/features/teacher/create_class_slot/presentation/providers/create_class_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sample class from the API docs, in domain terms.
CreateClassParams _params({
  ClassMode mode = ClassMode.offline,
  String? description = 'Algebra – Linear Equations',
  DateTime? validUntil,
  String? venueName = 'Room 3',
  String? venueAddress = '2nd Floor, Main Building',
}) => CreateClassParams(
  title: 'Class 10 – Mathematics',
  description: description,
  subjects: const ['Mathematics'],
  classes: const ['Class 10'],
  day: ScheduleDay.monday,
  startTime: const SlotTime(hour: 9, minute: 0),
  endTime: const SlotTime(hour: 10, minute: 0),
  validFrom: DateTime(2026, 8, 10),
  validUntil: validUntil,
  mode: mode,
  venueName: venueName,
  venueAddress: venueAddress,
);

/// Records what was posted and answers with [response].
class _RecordingApiClient implements IApiClient {
  _RecordingApiClient({this.response});

  final Map<String, dynamic>? response;

  String? postedPath;
  Object? postedBody;

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    postedPath = path;
    postedBody = data;

    return (response ?? {'success': true, 'code': 201}) as T;
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('The form only writes.');

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();
}

class _FakeDataSource implements CreateClassRemoteDataSource {
  _FakeDataSource({this.throws});

  final Object? throws;
  int calls = 0;

  @override
  Future<void> createClass(request) async {
    calls++;
    final error = throws;
    if (error != null) throw error;
  }
}

void main() {
  group('CreateClassMapper', () {
    test('builds the documented payload', () {
      final json = CreateClassMapper.toRequest(_params()).toJson();

      expect(json, {
        'title': 'Class 10 – Mathematics',
        'description': 'Algebra – Linear Equations',
        'subjects': ['Mathematics'],
        'classes': ['Class 10'],
        'dayOfWeek': 1,
        'startTime': '09:00',
        'endTime': '10:00',
        'validFrom': '2026-08-10',
        // No end date picked: sent as an empty string, not omitted.
        'validUntil': '',
        'mode': 'offline',
        'venueName': 'Room 3',
        'venueAddress': '2nd Floor, Main Building',
      });
    });

    test('sends an end date only once one is picked', () {
      final json = CreateClassMapper.toRequest(
        _params(validUntil: DateTime(2026, 12, 31)),
      ).toJson();

      expect(json['validUntil'], '2026-12-31');
    });

    test('drops the venue for an online class', () {
      final json = CreateClassMapper.toRequest(
        _params(mode: ClassMode.online),
      ).toJson();

      expect(json['mode'], 'online');
      expect(json['venueName'], isEmpty);
      expect(json['venueAddress'], isEmpty);
    });

    test('a whitespace-only optional field is blanked, not sent as typed', () {
      final json = CreateClassMapper.toRequest(
        _params(description: '   ', venueAddress: ''),
      ).toJson();

      expect(json['description'], isEmpty);
      expect(json['venueAddress'], isEmpty);
    });
  });

  group('ClassSlotFormController.toParams', () {
    test('carries the filled-in form across in wire-ready shapes', () {
      final controller = ClassSlotFormController()
        ..title.text = 'Class 10 – Mathematics'
        ..description.text = 'Algebra – Linear Equations'
        ..subjects.value = const ['Mathematics']
        ..classes.value = const ['Class 10']
        ..day.value = ScheduleDay.monday
        ..startTime.value = const TimeOfDay(hour: 9, minute: 0)
        ..endTime.value = const TimeOfDay(hour: 10, minute: 0)
        ..validFrom.value = DateTime(2026, 8, 10)
        ..venueName.text = 'Room 3'
        ..venueAddress.text = '2nd Floor, Main Building';
      addTearDown(controller.dispose);

      final json = CreateClassMapper.toRequest(controller.toParams()).toJson();

      expect(json['dayOfWeek'], 1);
      expect(json['startTime'], '09:00');
      expect(json['endTime'], '10:00');
      expect(json['validFrom'], '2026-08-10');
      expect(json['mode'], 'offline');
      expect(json['validUntil'], isEmpty);
    });
  });

  group('CreateClassRemoteDataSourceImpl', () {
    test('posts the body to the class-slot endpoint', () async {
      final client = _RecordingApiClient();

      await CreateClassRemoteDataSourceImpl(
        client,
      ).createClass(CreateClassMapper.toRequest(_params()));

      expect(client.postedPath, ApiEndpoints.classSlots);
      expect(
        (client.postedBody! as Map<String, dynamic>)['title'],
        'Class 10 – Mathematics',
      );
    });

    test('a rejecting envelope throws with the server message', () async {
      final client = _RecordingApiClient(
        response: {'success': false, 'message': 'That slot overlaps another.'},
      );

      expect(
        () => CreateClassRemoteDataSourceImpl(
          client,
        ).createClass(CreateClassMapper.toRequest(_params())),
        throwsA(
          isA<ApiException>().having(
            (exception) => exception.message,
            'message',
            'That slot overlaps another.',
          ),
        ),
      );
    });
  });

  group('CreateClassRepositoryImpl', () {
    test('turns a thrown ApiException into a failure', () async {
      final result = await CreateClassRepositoryImpl(
        remoteDataSource: _FakeDataSource(
          throws: const ApiException(
            message: 'No internet connection.',
            type: ApiExceptionType.network,
          ),
        ),
      ).createClass(_params());

      expect(result, isA<ApiFailure<void>>());
      expect(
        (result as ApiFailure<void>).exception.message,
        'No internet connection.',
      );
    });
  });

  group('CreateClassNotifier', () {
    ProviderContainer containerWith(IApiClient client) {
      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'a successful submit reports created and clears the spinner',
      () async {
        final container = containerWith(_RecordingApiClient());
        // Listened to so the auto-disposed notifier survives the await.
        container.listen(createClassNotifierProvider, (_, _) {});

        final created = await container
            .read(createClassNotifierProvider.notifier)
            .submit(_params());

        expect(created, isTrue);
        final state = container.read(createClassNotifierProvider);
        expect(state.isCreated, isTrue);
        expect(state.isSubmitting, isFalse);
        expect(state.error, isNull);
      },
    );

    test('a failed submit keeps the form and holds the error', () async {
      final container = containerWith(
        _RecordingApiClient(
          response: {
            'success': false,
            'message': 'That slot overlaps another.',
          },
        ),
      );
      container.listen(createClassNotifierProvider, (_, _) {});

      final created = await container
          .read(createClassNotifierProvider.notifier)
          .submit(_params());

      expect(created, isFalse);
      final state = container.read(createClassNotifierProvider);
      expect(state.isCreated, isFalse);
      expect(state.isSubmitting, isFalse);
      expect(state.error?.message, 'That slot overlaps another.');
    });
  });
}
