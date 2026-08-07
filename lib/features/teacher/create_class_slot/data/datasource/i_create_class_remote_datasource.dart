import '../model/create_class_request.dart';

abstract interface class CreateClassRemoteDataSource {
  Future<void> createClass(CreateClassRequest request);
}
