import '../../domain/entities/resource.dart';
import '../../domain/entities/resource_status.dart';

/// Contract for wherever resource data actually lives. [ResourceRepositoryImpl]
/// depends only on this abstraction, so swapping the current
/// [MockResourceDataSource] for a real backend later — e.g. an
/// `ApiResourceDataSource` that calls a REST/GraphQL API — means:
///
/// 1. Implement this interface against the API.
/// 2. Point `resourceDataSourceProvider` (in `repository_providers.dart`) at
///    the new implementation.
///
/// Nothing in the domain or presentation layers needs to change.
abstract class ResourceDataSource {
  /// The full roster for [date], with each person's status/notes for that
  /// day resolved.
  Future<List<Resource>> fetch(DateTime date);

  /// Sets [resourceId]'s status for [date] and returns the updated record.
  Future<Resource> setStatus(DateTime date, String resourceId, ResourceStatus status);

  /// Sets [resourceId]'s notes for [date] and returns the updated record.
  Future<Resource> setNotes(DateTime date, String resourceId, String notes);

  /// Adds a new resource to the roster (day-independent).
  Future<Resource> addResource({required String name, required String mobileNumber});

  /// Edits a resource's master profile (day-independent).
  Future<void> updateResource(String resourceId, {required String name, required String mobileNumber});

  /// Removes a resource from the roster entirely.
  Future<void> deleteResource(String resourceId);
}
