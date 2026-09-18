import '../entities/resource.dart';
import '../repositories/resource_repository.dart';

/// Fetches the roster and status entries for a given day.
class GetResourcesUseCase {
  const GetResourcesUseCase(this._repository);

  final ResourceRepository _repository;

  Future<List<Resource>> call(DateTime date) => _repository.getResources(date);
}
