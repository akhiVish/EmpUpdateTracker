import '../entities/resource.dart';
import '../repositories/resource_repository.dart';

/// Persists the free-text WhatsApp/status note pasted against a resource.
class UpdateResourceNotesUseCase {
  const UpdateResourceNotesUseCase(this._repository);

  final ResourceRepository _repository;

  Future<Resource> call(DateTime date, String resourceId, String notes) {
    return _repository.updateNotes(date, resourceId, notes);
  }
}
