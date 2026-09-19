import 'package:flutter/foundation.dart';

import 'resource_status.dart';

/// One day in a single resource's history on the Reports screen: either
/// their status + note for a working day, or an off day (weekly off /
/// holiday) that carries no status.
@immutable
class ResourceHistoryPoint {
  const ResourceHistoryPoint({required this.date, required this.status, required this.notes}) : offLabel = null;

  /// An off day. [status] and [notes] are placeholders and must be ignored.
  const ResourceHistoryPoint.offDay({required this.date, required String this.offLabel})
      : status = ResourceStatus.notUpdated,
        notes = '';

  final DateTime date;
  final ResourceStatus status;
  final String notes;

  /// Why the day is off (e.g. "Weekly off · Sunday"); null on working days.
  final String? offLabel;

  bool get isOffDay => offLabel != null;
}
