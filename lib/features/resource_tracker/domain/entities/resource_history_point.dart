import 'package:flutter/foundation.dart';

import 'resource_status.dart';

/// One day's status + note for a single resource, used by the Reports
/// screen's per-resource drill-down.
@immutable
class ResourceHistoryPoint {
  const ResourceHistoryPoint({required this.date, required this.status, required this.notes});

  final DateTime date;
  final ResourceStatus status;
  final String notes;
}
