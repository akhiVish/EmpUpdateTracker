import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/resource_history_point.dart';
import '../../../domain/entities/resource_status.dart';
import '../resource_list/status_style.dart';

/// Day-by-day timeline of one resource's status + notes, most recent day
/// first.
class ResourceHistoryList extends StatelessWidget {
  const ResourceHistoryList({super.key, required this.points});

  final List<ResourceHistoryPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No history in this range',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final reversed = points.reversed.toList();

    return Column(
      children: [
        _SummaryRow(points: points),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversed.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor),
          itemBuilder: (context, index) {
            final point = reversed[index];
            final hasNotes = point.notes.trim().isNotEmpty;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      DateFormat('EEE, MMM d').format(point.date),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: _StatusBadge(status: point.status),
                  ),
                  Expanded(
                    child: Text(
                      hasNotes ? point.notes : 'No note',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(alpha: hasNotes ? 0.8 : 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.points});

  final List<ResourceHistoryPoint> points;

  @override
  Widget build(BuildContext context) {
    final updated = points.where((p) => p.status == ResourceStatus.updated).length;
    final onLeave = points.where((p) => p.status == ResourceStatus.onLeave).length;
    final notUpdated = points.where((p) => p.status == ResourceStatus.notUpdated).length;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _SummaryChip(color: ResourceStatus.updated.color, label: 'Updated', count: updated),
        _SummaryChip(color: ResourceStatus.onLeave.color, label: 'On Leave', count: onLeave),
        _SummaryChip(color: ResourceStatus.notUpdated.color, label: 'Not Updated', count: notUpdated),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.color, required this.label, required this.count});

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ResourceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(status.shortLabel, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11.5)),
        ],
      ),
    );
  }
}
