import '../repositories/resource_repository.dart';

/// Removes a resource from the roster entirely (every day, past and
/// future), used by the Resources directory's delete action.
class DeleteResourceUseCase {
  const DeleteResourceUseCase(this._repository);

  final ResourceRepository _repository;

  Future<void> call(String resourceId) => _repository.deleteResource(resourceId);
}
