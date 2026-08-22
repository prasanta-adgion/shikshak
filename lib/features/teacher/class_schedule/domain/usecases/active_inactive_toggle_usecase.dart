import '../../../../../core/network/api_result.dart';
import '../entities/class_slot.dart';
import '../params/set_slot_active_params.dart';
import '../repositories/class_schedule_repository.dart';

class ClassActiveInactiveToggleUseCase {
  const ClassActiveInactiveToggleUseCase(this._repository);

  final ClassScheduleRepository _repository;

  Future<ApiResult<ClassSlot?>> call(SetSlotActiveParams params) =>
      _repository.classActiveInactiveToggle(
        slotId: params.slotId,
        isActive: params.isActive,
      );
}
