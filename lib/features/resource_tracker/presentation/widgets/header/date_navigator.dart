import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/date_formatter.dart';
import '../../providers/dashboard_filters_provider.dart';

/// Date picker with quick Previous/Next day toggles, defaulted to today.
class DateNavigator extends ConsumerWidget {
  const DateNavigator({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime current) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(current.year - 2),
      lastDate: today,
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).set(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final isToday = !selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Previous day',
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => ref.read(selectedDateProvider.notifier).previousDay(),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _pickDate(context, ref, selectedDate),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    AppDateFormatter.label(selectedDate),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: isToday ? null : () => ref.read(selectedDateProvider.notifier).nextDay(),
          ),
        ],
      ),
    );
  }
}
