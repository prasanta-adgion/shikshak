import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/class_schedule_remote_datasource.dart';
import '../../data/repository/class_schedule_repository_impl.dart';
import '../../domain/repositories/class_schedule_repository.dart';
import '../../domain/usecases/get_class_calendar_usecase.dart';
import '../../domain/usecases/get_class_slots_usecase.dart';
import '../../domain/usecases/active_inactive_toggle_usecase.dart';
import '../notifier/class_schedule_notifier.dart';
import '../notifier/class_slots_notifier.dart';
import '../state/class_schedule_state.dart';
import '../state/class_slots_state.dart';

final classScheduleRemoteDataSourceProvider =
    Provider<ClassScheduleRemoteDataSource>(
      (ref) => ClassScheduleRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final classScheduleRepositoryProvider = Provider<ClassScheduleRepository>((
  ref,
) {
  return ClassScheduleRepositoryImpl(
    remoteDataSource: ref.watch(classScheduleRemoteDataSourceProvider),
  );
});

final getClassCalendarUseCaseProvider = Provider<GetClassCalendarUseCase>(
  (ref) => GetClassCalendarUseCase(ref.watch(classScheduleRepositoryProvider)),
);

final getClassSlotsUseCaseProvider = Provider<GetClassSlotsUseCase>(
  (ref) => GetClassSlotsUseCase(ref.watch(classScheduleRepositoryProvider)),
);

final classActiveInactiveToggleProvider =
    Provider<ClassActiveInactiveToggleUseCase>(
      (ref) => ClassActiveInactiveToggleUseCase(
        ref.watch(classScheduleRepositoryProvider),
      ),
    );

/// Dropped with the screen, so reopening the Schedule tab re-reads the server
/// rather than showing what the last visit left behind.
final classScheduleNotifierProvider =
    NotifierProvider<ClassScheduleNotifier, ClassScheduleState>(
      ClassScheduleNotifier.new,
      isAutoDispose: true,
    );

/// Backs the All Slots tab. Auto-disposed for the same reason as the
/// calendar's: a reopened tab should re-read rather than replay.
final classSlotsNotifierProvider =
    NotifierProvider<ClassSlotsNotifier, ClassSlotsState>(
      ClassSlotsNotifier.new,
      isAutoDispose: true,
    );
