import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/day_info.dart';
import '../../providers/holidays_provider.dart';

/// Shown on the Dashboard instead of the metrics and roster when the
/// selected date is a weekly off or a holiday.
class DayOffBanner extends ConsumerWidget {
  const DayOffBanner({super.key, required this.info});

  final DayInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final isHoliday = info.type == DayType.holiday;
    final accent = isHoliday ? AppColors.amber : AppColors.indigo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isHoliday ? Icons.celebration_rounded : Icons.weekend_rounded, color: accent, size: 26),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.description,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No updates are expected on ${DateFormat('EEEE, MMM d').format(info.date)}. '
                    'This day is left out of the dashboard counts and the reports.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            if (isHoliday)
              TextButton.icon(
                onPressed: () => ref.read(holidaysProvider.notifier).deleteHoliday(info.holiday!.id),
                icon: const Icon(Icons.event_available_rounded, size: 18),
                label: const Text('Remove holiday'),
              ),
          ],
        ),
      ),
    );
  }
}
