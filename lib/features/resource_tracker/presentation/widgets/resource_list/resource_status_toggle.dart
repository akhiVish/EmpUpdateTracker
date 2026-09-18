import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resource.dart';
import '../../../domain/entities/resource_status.dart';
import '../../providers/resource_list_provider.dart';
import 'status_style.dart';

/// Three-state SegmentedButton (Updated / On Leave / Pending) that writes
/// straight through to [ResourceListNotifier], which optimistically updates
/// the summary metrics.
class ResourceStatusToggle extends ConsumerWidget {
  const ResourceStatusToggle({super.key, required this.resource, this.dense = false});

  final Resource resource;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeColor = resource.status.color;

    return SegmentedButton<ResourceStatus>(
      segments: [
        for (final status in ResourceStatus.values)
          ButtonSegment(
            value: status,
            icon: Icon(status.icon, size: 16, color: status.color),
            label: dense
                ? null
                : Text(
                    status.shortLabel,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
      ],
      selected: {resource.status},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        ref.read(resourceListProvider.notifier).updateStatus(resource.id, selection.first);
      },
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        selectedBackgroundColor: activeColor.withValues(alpha: 0.16),
        selectedForegroundColor: activeColor,
        padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: 4),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
