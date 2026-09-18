import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/resource_metrics.dart';

/// Donut chart summarizing one day's status split, with the total shown in
/// the empty center.
class SnapshotDonutChart extends StatelessWidget {
  const SnapshotDonutChart({super.key, required this.metrics});

  final ResourceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (metrics.total == 0) {
      return Center(
        child: Text('No data', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 46,
              sections: [
                if (metrics.updated > 0)
                  PieChartSectionData(
                    value: metrics.updated.toDouble(),
                    color: AppColors.emerald,
                    radius: 26,
                    showTitle: false,
                  ),
                if (metrics.onLeave > 0)
                  PieChartSectionData(
                    value: metrics.onLeave.toDouble(),
                    color: AppColors.amber,
                    radius: 26,
                    showTitle: false,
                  ),
                if (metrics.notUpdated > 0)
                  PieChartSectionData(
                    value: metrics.notUpdated.toDouble(),
                    color: AppColors.crimson,
                    radius: 26,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${metrics.total}',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                'total',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
