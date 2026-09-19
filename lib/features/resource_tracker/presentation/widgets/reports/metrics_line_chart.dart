import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/daily_metrics_point.dart';
import '../../../domain/entities/resource_metrics.dart';

/// Line chart with three series (Updated / On Leave / Not Updated) plotted
/// across the day range chosen on the Reports screen.
class MetricsLineChart extends StatelessWidget {
  const MetricsLineChart({super.key, required this.points});

  final List<DailyMetricsPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final labelInterval = points.length > 10 ? (points.length / 6).ceil().toDouble() : 1.0;

    final maxValue = points.fold<int>(0, (max, p) => [max, p.metrics.total].reduce((a, b) => a > b ? a : b));
    final maxY = (maxValue == 0 ? 4 : maxValue) * 1.2;

    return AspectRatio(
      aspectRatio: 1.9,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).clamp(1, double.infinity),
            getDrawingHorizontalLine: (_) => FlLine(color: theme.dividerColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value != value.roundToDouble()) return const SizedBox.shrink();
                  return Text('${value.toInt()}', style: TextStyle(fontSize: 11, color: muted));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: labelInterval,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= points.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MMM d').format(points[index].date),
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (barData, indicators) => indicators.map((i) {
              return TouchedSpotIndicatorData(
                FlLine(color: barData.color?.withValues(alpha: 0.3) ?? AppColors.indigo, strokeWidth: 2),
                FlDotData(show: true),
              );
            }).toList(),
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.surface,
              tooltipBorder: BorderSide(color: theme.dividerColor),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.round();
                  final label = index >= 0 && index < points.length ? DateFormat('MMM d').format(points[index].date) : '';
                  return LineTooltipItem(
                    '$label\n${spot.y.toInt()}',
                    TextStyle(color: spot.bar.color ?? theme.colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            _series(points, AppColors.emerald, (m) => m.updated),
            _series(points, AppColors.amber, (m) => m.onLeave),
            _series(points, AppColors.crimson, (m) => m.notUpdated),
          ],
        ),
      ),
    );
  }

  LineChartBarData _series(List<DailyMetricsPoint> points, Color color, int Function(ResourceMetrics) select) {
    return LineChartBarData(
      spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), select(points[i].metrics).toDouble())],
      isCurved: true,
      curveSmoothness: 0.25,
      color: color,
      barWidth: 2.5,
      // A line needs two points; show dots so a 1-3 day range isn't blank.
      dotData: FlDotData(show: points.length <= 3),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
    );
  }
}
