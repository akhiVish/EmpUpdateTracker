import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/resource.dart';
import '../../domain/entities/resource_status.dart';
import 'resource_data_source.dart';

/// Firestore-backed [ResourceDataSource].
///
/// Schema:
/// - `resources/{resourceId}` — `{ name, mobileNumber }`, the day-independent
///   master roster.
/// - `dailyStatus/{resourceId}_{yyyy-MM-dd}` — `{ resourceId, date, status,
///   notes }`, one doc per person per day. A resource with no doc for a
///   given day defaults to Not Updated with no notes — nobody starts the
///   day pre-marked as anything.
class FirebaseResourceDataSource implements ResourceDataSource {
  FirebaseResourceDataSource({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _resources => _db.collection('resources');
  CollectionReference<Map<String, dynamic>> get _dailyStatus => _db.collection('dailyStatus');

  @override
  Future<List<Resource>> fetch(DateTime date) async {
    final day = _dateOnly(date);
    final resourceDocs = await _resources.orderBy('name').get();
    final statusDocs = await _dailyStatus.where('date', isEqualTo: Timestamp.fromDate(day)).get();

    final statusByResourceId = {
      for (final doc in statusDocs.docs) doc.data()['resourceId'] as String: doc.data(),
    };

    return [
      for (final doc in resourceDocs.docs) _buildResource(doc.id, doc.data(), statusByResourceId[doc.id]),
    ];
  }

  @override
  Future<Resource> setStatus(DateTime date, String resourceId, ResourceStatus status) async {
    await _upsertDailyStatus(date, resourceId, {'status': status.name});
    return _fetchOne(date, resourceId);
  }

  @override
  Future<Resource> setNotes(DateTime date, String resourceId, String notes) async {
    await _upsertDailyStatus(date, resourceId, {'notes': notes});
    return _fetchOne(date, resourceId);
  }

  @override
  Future<Resource> addResource({required String name, required String mobileNumber}) async {
    final doc = await _resources.add({'name': name, 'mobileNumber': mobileNumber});
    return Resource(id: doc.id, name: name, mobileNumber: mobileNumber, status: ResourceStatus.notUpdated);
  }

  @override
  Future<void> updateResource(String resourceId, {required String name, required String mobileNumber}) {
    return _resources.doc(resourceId).update({'name': name, 'mobileNumber': mobileNumber});
  }

  @override
  Future<void> deleteResource(String resourceId) async {
    await _resources.doc(resourceId).delete();

    // Clean up that resource's status history too, in batches of 500
    // (Firestore's per-batch write limit).
    final staleDocs = await _dailyStatus.where('resourceId', isEqualTo: resourceId).get();
    for (var i = 0; i < staleDocs.docs.length; i += 500) {
      final batch = _db.batch();
      for (final doc in staleDocs.docs.skip(i).take(500)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _upsertDailyStatus(DateTime date, String resourceId, Map<String, dynamic> fields) {
    final day = _dateOnly(date);
    return _dailyStatus.doc(_statusDocId(resourceId, day)).set({
      'resourceId': resourceId,
      'date': Timestamp.fromDate(day),
      ...fields,
    }, SetOptions(merge: true));
  }

  Future<Resource> _fetchOne(DateTime date, String resourceId) async {
    final day = _dateOnly(date);
    final resourceDoc = await _resources.doc(resourceId).get();
    final resourceData = resourceDoc.data();
    if (resourceData == null) {
      throw StateError('Resource "$resourceId" not found');
    }
    final statusDoc = await _dailyStatus.doc(_statusDocId(resourceId, day)).get();
    return _buildResource(resourceDoc.id, resourceData, statusDoc.data());
  }

  Resource _buildResource(String id, Map<String, dynamic> resourceData, Map<String, dynamic>? statusData) {
    return Resource(
      id: id,
      name: resourceData['name'] as String? ?? '',
      mobileNumber: resourceData['mobileNumber'] as String? ?? '',
      status: _statusFromName(statusData?['status'] as String?),
      notes: statusData?['notes'] as String? ?? '',
    );
  }

  ResourceStatus _statusFromName(String? name) {
    for (final status in ResourceStatus.values) {
      if (status.name == name) return status;
    }
    return ResourceStatus.notUpdated;
  }

  String _statusDocId(String resourceId, DateTime day) => '${resourceId}_${_dateKey(day)}';

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
