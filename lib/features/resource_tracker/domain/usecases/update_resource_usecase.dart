import '../repositories/resource_repository.dart';

/// Edits a resource's master profile (name / mobile number) on the
/// Resources directory. Does not touch any day's status or notes.
class UpdateResourceUseCase {
  const UpdateResourceUseCase(this._repository);

  final ResourceRepository _repository;

  Future<void> call(String resourceId, {required String name, required String mobileNumber}) {
    return _repository.updateResource(resourceId, name: name, mobileNumber: mobileNumber);
  }
}
