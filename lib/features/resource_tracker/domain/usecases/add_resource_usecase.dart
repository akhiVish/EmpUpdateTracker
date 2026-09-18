import '../entities/resource.dart';
import '../repositories/resource_repository.dart';

/// Adds a brand-new resource (name + mobile number) to the master roster.
/// The new person appears on every day's roster from then on, starting
/// with a "Not Updated" status until they get one for a given day.
class AddResourceUseCase {
  const AddResourceUseCase(this._repository);

  final ResourceRepository _repository;

  Future<Resource> call({required String name, required String mobileNumber}) {
    return _repository.addResource(name: name, mobileNumber: mobileNumber);
  }
}
