import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../providers/dashboard_filters_provider.dart';
import '../../providers/resource_list_provider.dart';
import '../../providers/status_filter.dart';
import 'metric_card.dart';

/// The four live summary cards: Total / Updated / On Leave / Not Updated.
/// Tapping a card also applies the matching quick filter. On mobile these
/// lay out as a compact 2x2 grid instead of one per row.
class MetricsBanner extends ConsumerWidget {
  const MetricsBanner({super.key, required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(resourceMetricsProvider);
    final activeFilter = ref.watch(statusFilterProvider);
    final notifier = ref.read(statusFilterProvider.notifier);

    final total = MetricCard(
      label: 'Total Resources',
      value: metrics.total,
      icon: Icons.groups_rounded,
      accentColor: AppColors.indigo,
      selected: activeFilter == StatusFilter.all,
      onTap: () => notifier.set(StatusFilter.all),
    );
    final updated = MetricCard(
      label: 'Updated Status',
      value: metrics.updated,
      icon: Icons.check_circle_rounded,
      accentColor: AppColors.emerald,
      selected: activeFilter == StatusFilter.updated,
      onTap: () => notifier.set(StatusFilter.updated),
    );
    final onLeave = MetricCard(
      label: 'On Leave',
      value: metrics.onLeave,
      icon: Icons.wb_sunny_rounded,
      accentColor: AppColors.amber,
      selected: activeFilter == StatusFilter.onLeave,
      onTap: () => notifier.set(StatusFilter.onLeave),
    );
    final notUpdated = MetricCard(
      label: 'Not Updated',
      value: metrics.notUpdated,
      icon: Icons.error_rounded,
      accentColor: AppColors.crimson,
      selected: activeFilter == StatusFilter.notUpdated,
      onTap: () => notifier.set(StatusFilter.notUpdated),
    );

    if (deviceType == DeviceType.mobile) {
      // IntrinsicHeight resolves a concrete height for the Row before
      // `stretch` is applied — without it, `stretch` inside this unbounded
      // (scrollable) column asks for infinite height and crashes.
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: total),
                const SizedBox(width: 12),
                Expanded(child: updated),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: onLeave),
                const SizedBox(width: 12),
                Expanded(child: notUpdated),
              ],
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [total, updated, onLeave, notUpdated],
    );
  }
}
