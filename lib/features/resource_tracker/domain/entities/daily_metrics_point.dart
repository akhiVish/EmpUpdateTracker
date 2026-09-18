import 'package:flutter/foundation.dart';

import 'resource_metrics.dart';

/// One day's aggregate counts, used to plot trends on the Reports screen.
@immutable
class DailyMetricsPoint {
  const DailyMetricsPoint({required this.date, required this.metrics});

  final DateTime date;
  final ResourceMetrics metrics;
}
