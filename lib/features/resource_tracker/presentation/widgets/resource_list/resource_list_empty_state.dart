import 'package:flutter/material.dart';

/// Shown when search + filter combination yields no rows.
class ResourceListEmptyState extends StatelessWidget {
  const ResourceListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: muted),
          const SizedBox(height: 12),
          Text('No resources match your filters', style: theme.textTheme.titleMedium?.copyWith(color: muted)),
          const SizedBox(height: 4),
          Text('Try clearing the search or switching filters.', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        ],
      ),
    );
  }
}
