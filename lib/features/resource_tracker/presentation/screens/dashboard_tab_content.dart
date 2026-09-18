import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/resource_list_provider.dart';
import '../widgets/filters/quick_filters_bar.dart';
import '../widgets/header/dashboard_header.dart';
import '../widgets/metrics/metrics_banner.dart';
import '../widgets/resource_list/resource_card_list.dart';
import '../widgets/resource_list/resource_grid_view.dart';
import '../widgets/resource_list/resource_table_view.dart';

/// The "Dashboard" tab: date navigator, live metrics, quick filters and
/// the responsive status list/table/cards for the currently selected day.
class DashboardTabContent extends ConsumerWidget {
  const DashboardTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResources = ref.watch(resourceListProvider);
    final isInitialLoading = asyncResources.isLoading && !asyncResources.hasValue;
    final hasFailed = asyncResources.hasError && !asyncResources.hasValue;
    final isRefreshing = asyncResources.isLoading && asyncResources.hasValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = AppBreakpoints.deviceTypeFor(constraints.maxWidth);
        final horizontalPadding = switch (deviceType) {
          DeviceType.mobile => AppSpacing.md,
          DeviceType.tablet => AppSpacing.lg,
          DeviceType.desktop => AppSpacing.xl,
        };

        return Column(
          children: [
            if (isRefreshing) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: isInitialLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasFailed
                      ? const _LoadErrorState()
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DashboardHeader(deviceType: deviceType),
                              const SizedBox(height: AppSpacing.lg),
                              MetricsBanner(deviceType: deviceType),
                              const SizedBox(height: AppSpacing.lg),
                              const QuickFiltersBar(),
                              const SizedBox(height: AppSpacing.md),
                              switch (deviceType) {
                                DeviceType.desktop => const ResourceTableView(),
                                DeviceType.tablet => const ResourceGridView(),
                                DeviceType.mobile => const ResourceCardList(),
                              },
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          Text('Could not load today\'s roster', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
