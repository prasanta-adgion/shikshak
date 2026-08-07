import '../../../../../core/network/api_result.dart';
import '../params/create_class_params.dart';

abstract interface class CreateClassRepository {
  /// Files a new recurring class slot.
  Future<ApiResult<void>> createClass(CreateClassParams params);
}
