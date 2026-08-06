import '../../../../../../core/network/api_result.dart';
import '../entities/about_you.dart';
import '../repositories/about_you_repository.dart';

class GetAboutYouUseCase {
  const GetAboutYouUseCase(this._repository);

  final AboutYouRepository _repository;

  Future<ApiResult<AboutYou?>> call() => _repository.fetchAboutYou();
}
