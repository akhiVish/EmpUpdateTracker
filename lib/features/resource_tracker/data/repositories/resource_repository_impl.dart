import '../../domain/entities/resource.dart';
import '../../domain/entities/resource_status.dart';
import '../../domain/repositories/resource_repository.dart';
import '../datasources/resource_data_source.dart';

/// Bridges the domain layer to a [ResourceDataSource]. Depending on the
/// abstraction (not the mock implementation) means swapping in a real API
/// later never requires touching this file — only `repository_providers.dart`.
class ResourceRepositoryImpl implements ResourceRepository {
  const ResourceRepositoryImpl(this._dataSource);

  final ResourceDataSource _dataSource;

  @override
  Future<List<Resource>> getResources(DateTime date) => _dataSource.fetch(date);

  @override
  Future<Resource> updateStatus(DateTime date, String resourceId, ResourceStatus status) {
    return _dataSource.setStatus(date, resourceId, status);
  }

  @override
  Future<Resource> updateNotes(DateTime date, String resourceId, String notes) {
    return _dataSource.setNotes(date, resourceId, notes);
  }

  @override
  Future<Resource> addResource({required String name, required String mobileNumber}) {
    return _dataSource.addResource(name: name, mobileNumber: mobileNumber);
  }

  @override
  Future<void> updateResource(String resourceId, {required String name, required String mobileNumber}) {
    return _dataSource.updateResource(resourceId, name: name, mobileNumber: mobileNumber);
  }

  @override
  Future<void> deleteResource(String resourceId) {
    return _dataSource.deleteResource(resourceId);
  }
}
