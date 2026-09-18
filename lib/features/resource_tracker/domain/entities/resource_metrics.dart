import 'package:flutter/foundation.dart';

import 'resource.dart';
import 'resource_status.dart';

/// Aggregate counts shown in the top summary banner and filter chips.
@immutable
class ResourceMetrics {
  const ResourceMetrics({
    required this.total,
    required this.updated,
    required this.onLeave,
    required this.notUpdated,
  });

  factory ResourceMetrics.fromResources(List<Resource> resources) {
    var updated = 0;
    var onLeave = 0;
    var notUpdated = 0;
    for (final resource in resources) {
      switch (resource.status) {
        case ResourceStatus.updated:
          updated++;
        case ResourceStatus.onLeave:
          onLeave++;
        case ResourceStatus.notUpdated:
          notUpdated++;
      }
    }
    return ResourceMetrics(
      total: resources.length,
      updated: updated,
      onLeave: onLeave,
      notUpdated: notUpdated,
    );
  }

  const ResourceMetrics.zero()
      : total = 0,
        updated = 0,
        onLeave = 0,
        notUpdated = 0;

  final int total;
  final int updated;
  final int onLeave;
  final int notUpdated;
}
