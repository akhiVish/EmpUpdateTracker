import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resource.dart';
import '../../providers/resource_list_provider.dart';
import 'status_style.dart';

/// One-click "quick action" that cycles Updated -> On Leave -> Pending.
class ResourceCycleButton extends ConsumerWidget {
  const ResourceCycleButton({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filledTonal(
      tooltip: 'Cycle to next status (currently ${resource.status.label})',
      icon: const Icon(Icons.sync_rounded, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: resource.status.color.withValues(alpha: 0.12),
        foregroundColor: resource.status.color,
        minimumSize: const Size(36, 36),
      ),
      onPressed: () => ref.read(resourceListProvider.notifier).cycleStatus(resource.id),
    );
  }
}
