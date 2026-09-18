import '../entities/resource.dart';
import '../entities/resource_status.dart';
import '../repositories/resource_repository.dart';

/// Persists a status change (Updated / On Leave / Pending) for one resource.
class UpdateResourceStatusUseCase {
  const UpdateResourceStatusUseCase(this._repository);

  final ResourceRepository _repository;

  Future<Resource> call(DateTime date, String resourceId, ResourceStatus status) {
    return _repository.updateStatus(date, resourceId, status);
  }
}
