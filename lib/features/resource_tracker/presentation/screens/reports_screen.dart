import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/resource.dart';
import '../providers/reports_provider.dart';
import '../providers/resource_list_provider.dart';
import '../widgets/reports/metrics_legend.dart';
import '../widgets/reports/metrics_line_chart.dart';
import '../widgets/reports/report_range_selector.dart';
import '../widgets/reports/report_resource_picker.dart';
import '../widgets/reports/resource_history_list.dart';
import '../widgets/reports/snapshot_donut_chart.dart';
import '../widgets/resource_list/resource_avatar.dart';

/// Reports screen: aggregate trend charts for the whole team, or — once a
/// resource is picked — that person's day-by-day status/notes history.
/// Both are driven by the same quick-range selector (Today / Last 3 / Last
/// 7 / Last 30 / a custom picked range).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedResourceId = ref.watch(selectedReportResourceIdProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = AppBreakpoints.deviceTypeFor(constraints.maxWidth);
        final horizontalPadding = switch (deviceType) {
          DeviceType.mobile => AppSpacing.md,
          DeviceType.tablet => AppSpacing.lg,
          DeviceType.desktop => AppSpacing.xl,
        };

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportsHeader(deviceType: deviceType),
              const SizedBox(height: AppSpacing.md),
              const ReportRangeSelector(),
              const SizedBox(height: AppSpacing.lg),
              if (selectedResourceId != null)
                _ResourceReportCard(resourceId: selectedResourceId)
              else if (deviceType == DeviceType.desktop)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Expanded(flex: 2, child: _TrendCard()),
                      SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 1, child: _SnapshotCard()),
                    ],
                  ),
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TrendCard(),
                    SizedBox(height: AppSpacing.lg),
                    _SnapshotCard(),
                  ],
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader({required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = deviceType == DeviceType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reports & Trends',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'How the team\'s daily updates have trended recently.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: AppSpacing.md),
        ReportResourcePicker(width: isMobile ? double.infinity : 320),
      ],
    );
  }
}

class _ResourceReportCard extends ConsumerWidget {
  const _ResourceReportCard({required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resources = ref.watch(dailyResourcesProvider);
    Resource? resource;
    for (final r in resources) {
      if (r.id == resourceId) {
        resource = r;
        break;
      }
    }
    final history = ref.watch(resourceHistoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (resource != null) ...[
                  ResourceAvatar(resource: resource, radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(resource.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          resource.mobileNumber,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ),
                ] else
                  const Expanded(child: Text('Resource not found')),
                TextButton.icon(
                  onPressed: () => ref.read(selectedReportResourceIdProvider.notifier).clear(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('All Resources'),
                ),
              ],
            ),
            const Divider(height: 32),
            history.when(
              data: (points) => ResourceHistoryList(points: points),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Could not load history', style: TextStyle(color: theme.colorScheme.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends ConsumerWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(metricsHistoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily status trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const MetricsLegend(),
            const SizedBox(height: 20),
            history.when(
              data: (points) => points.isEmpty
                  ? const _NoWorkingDays(aspectRatio: 1.9)
                  : MetricsLineChart(points: points),
              loading: () => const AspectRatio(aspectRatio: 1.9, child: Center(child: CircularProgressIndicator())),
              error: (error, stack) => AspectRatio(
                aspectRatio: 1.9,
                child: Center(child: Text('Could not load trend data', style: TextStyle(color: theme.colorScheme.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotCard extends ConsumerWidget {
  const _SnapshotCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(metricsHistoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest working day',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            history.when(
              data: (points) => points.isEmpty
                  ? const _NoWorkingDays(aspectRatio: 1.3)
                  : SnapshotDonutChart(metrics: points.last.metrics),
              loading: () => const AspectRatio(aspectRatio: 1.3, child: Center(child: CircularProgressIndicator())),
              error: (error, stack) => AspectRatio(
                aspectRatio: 1.3,
                child: Center(child: Text('Could not load snapshot', style: TextStyle(color: theme.colorScheme.error))),
              ),
            ),
            const SizedBox(height: 16),
            const MetricsLegend(),
          ],
        ),
      ),
    );
  }
}

class _NoWorkingDays extends StatelessWidget {
  const _NoWorkingDays({required this.aspectRatio});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Center(
        child: Text(
          'No working days in this range',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
