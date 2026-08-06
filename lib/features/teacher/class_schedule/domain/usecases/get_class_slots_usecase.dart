import '../../../../../core/network/api_result.dart';
import '../entities/class_slot.dart';
import '../repositories/class_schedule_repository.dart';

class GetClassSlotsUseCase {
  const GetClassSlotsUseCase(this._repository);

  final ClassScheduleRepository _repository;

  Future<ApiResult<List<ClassSlot>>> call() => _repository.fetchSlots();
}
