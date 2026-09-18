import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reports_provider.dart';

/// Quick-range chips (Today / Last 3 / Last 7 / Last 30 / Custom) that
/// drive every chart and history list on the Reports screen.
class ReportRangeSelector extends ConsumerWidget {
  const ReportRangeSelector({super.key});

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final current = ref.read(effectiveReportRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: current,
    );
    if (picked != null) {
      ref.read(customReportRangeProvider.notifier).set(picked);
      ref.read(reportRangePresetProvider.notifier).set(ReportRangePreset.custom);
    }
  }

  String _chipLabel(ReportRangePreset preset, DateTimeRange? custom) {
    if (preset != ReportRangePreset.custom) return preset.label;
    if (custom == null) return preset.label;
    final format = DateFormat('MMM d');
    return '${format.format(custom.start)} - ${format.format(custom.end)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePreset = ref.watch(reportRangePresetProvider);
    final customRange = ref.watch(customReportRangeProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final preset in ReportRangePreset.values)
          ChoiceChip(
            label: Text(_chipLabel(preset, customRange)),
            selected: activePreset == preset,
            onSelected: (_) {
              if (preset == ReportRangePreset.custom) {
                _pickCustomRange(context, ref);
              } else {
                ref.read(reportRangePresetProvider.notifier).set(preset);
              }
            },
            showCheckmark: false,
            selectedColor: primary.withValues(alpha: 0.16),
            side: BorderSide(color: activePreset == preset ? primary : theme.dividerColor),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: activePreset == preset ? primary : theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
      ],
    );
  }
}
