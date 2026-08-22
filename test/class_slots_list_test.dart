import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksak/core/network/api_exception.dart';
import 'package:shiksak/core/network/api_result.dart';
import 'package:shiksak/features/teacher/class_schedule/data/datasource/class_schedule_remote_datasource.dart';
import 'package:shiksak/features/teacher/class_schedule/data/model/class_calendar_response_model.dart';
import 'package:shiksak/features/teacher/class_schedule/data/model/class_slot_list_response_model.dart';
import 'package:shiksak/features/teacher/class_schedule/data/model/class_slot_model.dart';
import 'package:shiksak/features/teacher/class_schedule/data/repository/class_schedule_repository_impl.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/class_slot.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/date_range.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/schedule_calendar.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/schedule_day.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/entities/slot_time.dart';
import 'package:shiksak/features/teacher/class_schedule/domain/repositories/class_schedule_repository.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/notifier/class_slots_notifier.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:shiksak/features/teacher/class_schedule/presentation/state/class_slots_state.dart';

import 'fixtures/class_slot_list_response.dart';

class _FakeDataSource implements ClassScheduleRemoteDataSource {
  _FakeDataSource({this.models = const [], this.throws, this.toggled});

  final List<ClassSlotModel> models;
  final Object? throws;

  /// What the PATCH echoes back. Null stands for the envelope-only reply.
  final ClassSlotModel? toggled;

  ({String slotId, bool isActive})? toggleRequest;

  @override
  Future<List<ClassSlotModel>> fetchSlots() async {
    final error = throws;
    if (error != null) throw error;
    return models;
  }

  @override
  Future<ClassCalendarDataModel> fetchWeeklyCalendar(DateRange range) async =>
      const ClassCalendarDataModel();

  @override
  Future<ClassSlotModel?> setSlotActive({
    required String slotId,
    required bool isActive,
  }) async {
    toggleRequest = (slotId: slotId, isActive: isActive);
    final error = throws;
    if (error != null) throw error;
    return toggled;
  }
}

List<ClassSlotModel> _fixtureModels() => ClassSlotListResponseModel.fromJson(
  classSlotListResponseJson(),
).data!.items;

Future<List<ClassSlot>> _slotsFrom(_FakeDataSource remote) async {
  final result = await ClassScheduleRepositoryImpl(
    remoteDataSource: remote,
  ).fetchSlots();
  return result.dataOrNull!;
}

void main() {
  group('ClassSlotListResponseModel', () {
    test('reads every item in the payload', () {
      final response = ClassSlotListResponseModel.fromJson(
        classSlotListResponseJson(),
      );

      expect(response.success, isTrue);
      expect(response.data!.items, hasLength(6));
    });

    test('an unexpected data shape yields no items rather than throwing', () {
      final response = ClassSlotListResponseModel.fromJson({
        'success': true,
        'data': {'items': 'not-a-list'},
      });

      expect(response.data!.items, isEmpty);
    });
  });

  group('fetchSlots', () {
    test('orders by day, then by start time within the day', () async {
      final slots = await _slotsFrom(_FakeDataSource(models: _fixtureModels()));

      expect(slots.map((slot) => slot.title), [
        'Physics Classes', // Sunday
        'English classes', // Monday
        'Logarithm', // Thursday 09:00
        'Math', // Thursday 11:00
        'math', // Thursday 13:00
        'Classesss', // Friday
      ]);
    });

    test(
      'drops rows it cannot place instead of failing the whole load',
      () async {
        final slots = await _slotsFrom(
          _FakeDataSource(
            models: const [
              ClassSlotModel(id: 'good', dayOfWeek: 2, startTime: '09:00'),
              ClassSlotModel(id: 'no-day', startTime: '09:00'),
              ClassSlotModel(id: 'no-time', dayOfWeek: 3),
            ],
          ),
        );

        expect(slots.map((slot) => slot.id), ['good']);
      },
    );

    test('surfaces a datasource failure as ApiFailure', () async {
      const exception = ApiException(
        message: 'Server error. Try again later.',
        type: ApiExceptionType.server,
      );

      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: _FakeDataSource(throws: exception),
      ).fetchSlots();

      expect(result, isA<ApiFailure<List<ClassSlot>>>());
      expect(
        (result as ApiFailure<List<ClassSlot>>).exception.message,
        exception.message,
      );
    });

    test('an unexpected error is wrapped rather than thrown', () async {
      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: _FakeDataSource(throws: StateError('boom')),
      ).fetchSlots();

      expect(result, isA<ApiFailure<List<ClassSlot>>>());
    });
  });

  group('setSlotActive', () {
    test('sends the requested value and returns the echoed slot', () async {
      final remote = _FakeDataSource(
        toggled: const ClassSlotModel(
          id: 'slot-1',
          title: 'Physics',
          dayOfWeek: 1,
          startTime: '09:00',
          isActive: false,
        ),
      );

      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: remote,
      ).setSlotActive(slotId: 'slot-1', isActive: false);

      expect(remote.toggleRequest, (slotId: 'slot-1', isActive: false));
      expect(result.dataOrNull?.isActive, isFalse);
    });

    test('an envelope-only reply succeeds with no slot', () async {
      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: _FakeDataSource(),
      ).setSlotActive(slotId: 'slot-1', isActive: true);

      expect(result, isA<ApiSuccess<ClassSlot?>>());
      expect(result.dataOrNull, isNull);
    });

    test('a rejected toggle comes back as ApiFailure', () async {
      const exception = ApiException(
        message: 'Could not update the slot.',
        type: ApiExceptionType.server,
      );

      final result = await ClassScheduleRepositoryImpl(
        remoteDataSource: _FakeDataSource(throws: exception),
      ).setSlotActive(slotId: 'slot-1', isActive: false);

      expect(result, isA<ApiFailure<ClassSlot?>>());
    });
  });

  group('ClassSlotsState', () {
    Future<ClassSlotsState> fixtureState() async => ClassSlotsState(
      slots: await _slotsFrom(_FakeDataSource(models: _fixtureModels())),
      hasLoaded: true,
    );

    test(
      'groups slots under their day, weekday order, quiet days omitted',
      () async {
        final state = await fixtureState();

        expect(state.slotsByDay.keys, [
          ScheduleDay.sunday,
          ScheduleDay.monday,
          ScheduleDay.thursday,
          ScheduleDay.friday,
        ]);
        expect(state.slotsByDay[ScheduleDay.thursday], hasLength(3));
        expect(state.slotsByDay[ScheduleDay.wednesday], isNull);
      },
    );

    test('keeps the within-day order the repository sorted', () async {
      final state = await fixtureState();

      expect(
        state.slotsByDay[ScheduleDay.thursday]!.map((slot) => slot.startTime),
        const [
          SlotTime(hour: 9, minute: 0),
          SlotTime(hour: 11, minute: 0),
          SlotTime(hour: 13, minute: 0),
        ],
      );
    });

    test('sums what a full week of these slots would come to', () async {
      final state = await fixtureState();

      // Six one-hour slots.
      expect(state.slotCount, 6);
      expect(state.weeklyDurationLabel, '6h');
    });

    test('counts only the slots actually running as active', () {
      final state = ClassSlotsState(
        hasLoaded: true,
        slots: [
          _slot(id: 'running'),
          _slot(id: 'paused', isActive: false),
          _slot(id: 'ended', validUntil: DateTime(2020, 1, 1)),
          _slot(id: 'future', validFrom: DateTime(2999, 1, 1)),
        ],
      );

      expect(state.slotCount, 4);
      expect(state.activeCount, 1);
    });

    test('an empty list is empty, not a half-filled summary', () {
      const state = ClassSlotsState(hasLoaded: true);

      expect(state.isEmpty, isTrue);
      expect(state.slotsByDay, isEmpty);
      expect(state.activeCount, 0);
      expect(state.weeklyDurationLabel, '0m');
    });
  });

  group('ClassSlotsNotifier.toggleActive', () {
    /// A container holding a live subscription, so the auto-disposed notifier
    /// survives the awaits in these tests.
    (ProviderContainer, ClassSlotsNotifier) boot(_FakeRepository repository) {
      final container = ProviderContainer(
        overrides: [
          classScheduleRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        classSlotsNotifierProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      return (container, container.read(classSlotsNotifierProvider.notifier));
    }

    test('flips the card before the request lands, then takes the '
        'server\'s row', () async {
      final pending = Completer<ApiResult<ClassSlot?>>();

      final (container, notifier) = boot(
        _FakeRepository(
          slots: [_slot(id: 'slot-1')],
          toggle: () => pending.future,
        ),
      );
      await notifier.load();

      final toggling = notifier.toggleActive(
        container.read(classSlotsNotifierProvider).slots.single,
      );

      // In flight: already off on screen, and locked against a second tap.
      var state = container.read(classSlotsNotifierProvider);
      expect(state.slots.single.isActive, isFalse);
      expect(state.isToggling('slot-1'), isTrue);

      pending.complete(
        ApiResult.success(_slot(id: 'slot-1', isActive: false)),
      );
      await toggling;

      state = container.read(classSlotsNotifierProvider);
      expect(state.slots.single.isActive, isFalse);
      expect(state.isToggling('slot-1'), isFalse);
      expect(state.error, isNull);
    });

    test('a rejected toggle flips the card back and reports why', () async {
      const exception = ApiException(
        message: 'Could not update the slot.',
        type: ApiExceptionType.server,
      );

      final (container, notifier) = boot(
        _FakeRepository(
          slots: [_slot(id: 'slot-1')],
          toggle: () async => const ApiResult.failure(exception),
        ),
      );
      await notifier.load();

      await notifier.toggleActive(
        container.read(classSlotsNotifierProvider).slots.single,
      );

      final state = container.read(classSlotsNotifierProvider);
      expect(state.slots.single.isActive, isTrue);
      expect(state.isToggling('slot-1'), isFalse);
      expect(state.error?.message, exception.message);
    });
  });
}

/// Serves the notifier directly, so the toggle tests exercise the optimistic
/// flip rather than the transport under it.
class _FakeRepository implements ClassScheduleRepository {
  _FakeRepository({this.slots = const [], this.toggle});

  final List<ClassSlot> slots;

  /// Completes with what the PATCH resolved to. Left null, the toggle
  /// succeeds immediately with no echoed slot.
  final Future<ApiResult<ClassSlot?>> Function()? toggle;

  @override
  Future<ApiResult<List<ClassSlot>>> fetchSlots() async =>
      ApiResult.success(slots);

  @override
  Future<ApiResult<ScheduleCalendar>> fetchWeeklyCalendar(
    DateRange range,
  ) async => ApiResult.success(ScheduleCalendar(range: range));

  @override
  Future<ApiResult<ClassSlot?>> setSlotActive({
    required String slotId,
    required bool isActive,
  }) async => toggle == null ? const ApiResult.success(null) : await toggle!();
}

ClassSlot _slot({
  required String id,
  bool isActive = true,
  DateTime? validFrom,
  DateTime? validUntil,
}) => ClassSlot(
  id: id,
  title: id,
  day: ScheduleDay.monday,
  startTime: const SlotTime(hour: 9, minute: 0),
  endTime: const SlotTime(hour: 10, minute: 0),
  isActive: isActive,
  validFrom: validFrom,
  validUntil: validUntil,
);
