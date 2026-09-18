import '../entities/resource.dart';
import '../entities/resource_status.dart';

/// Contract the data layer must fulfil. The presentation layer only ever
/// depends on this abstraction, never on the concrete data source.
///
/// A resource's name and mobile number are master-profile fields (day
/// independent); status and notes are per-day. That split is why
/// [addResource]/[updateResource]/[deleteResource] take no date but
/// [getResources]/[updateStatus]/[updateNotes] do.
abstract class ResourceRepository {
  Future<List<Resource>> getResources(DateTime date);

  Future<Resource> updateStatus(DateTime date, String resourceId, ResourceStatus status);

  Future<Resource> updateNotes(DateTime date, String resourceId, String notes);

  Future<Resource> addResource({required String name, required String mobileNumber});

  Future<void> updateResource(String resourceId, {required String name, required String mobileNumber});

  Future<void> deleteResource(String resourceId);
}
