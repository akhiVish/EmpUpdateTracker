import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/resource_metrics.dart';
import '../../providers/dashboard_filters_provider.dart';
import '../../providers/resource_list_provider.dart';
import '../../providers/status_filter.dart';

/// Filter chips: All (70), Updated (50), On Leave (15), Not Updated (5).
class QuickFiltersBar extends ConsumerWidget {
  const QuickFiltersBar({super.key});

  Color _colorFor(StatusFilter filter) {
    switch (filter) {
      case StatusFilter.all:
        return AppColors.indigo;
      case StatusFilter.updated:
        return AppColors.emerald;
      case StatusFilter.onLeave:
        return AppColors.amber;
      case StatusFilter.notUpdated:
        return AppColors.crimson;
    }
  }

  int _countFor(StatusFilter filter, ResourceMetrics metrics) {
    switch (filter) {
      case StatusFilter.all:
        return metrics.total;
      case StatusFilter.updated:
        return metrics.updated;
      case StatusFilter.onLeave:
        return metrics.onLeave;
      case StatusFilter.notUpdated:
        return metrics.notUpdated;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(statusFilterProvider);
    final metrics = ref.watch(resourceMetricsProvider);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final filter in StatusFilter.values)
          _FilterChip(
            label: '${filter.label} (${_countFor(filter, metrics)})',
            color: _colorFor(filter),
            selected: activeFilter == filter,
            onSelected: () => ref.read(statusFilterProvider.notifier).set(filter),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withValues(alpha: 0.16),
      labelStyle: TextStyle(
        color: selected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide(color: selected ? color : Theme.of(context).dividerColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      showCheckmark: false,
    );
  }
}
