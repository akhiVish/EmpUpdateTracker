import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resource.dart';
import '../../providers/resource_list_provider.dart';
import 'resource_avatar.dart';
import 'resource_cycle_button.dart';
import 'resource_list_empty_state.dart';
import 'resource_notes_field.dart';
import 'resource_status_toggle.dart';

/// Desktop (> 1024px) interactive table: Resource details, status
/// SegmentedButton, task notes and a quick-cycle action per row.
class ResourceTableView extends ConsumerWidget {
  const ResourceTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(filteredResourcesProvider);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
            child: Row(
              children: [
                const SizedBox(width: 44),
                Expanded(
                  flex: 3,
                  child: _HeaderLabel('Resource Details'),
                ),
                const Expanded(flex: 4, child: _HeaderLabel('Status')),
                const Expanded(flex: 3, child: _HeaderLabel('Task Notes')),
                const SizedBox(width: 56, child: _HeaderLabel('Action', align: TextAlign.center)),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          if (resources.isEmpty)
            const ResourceListEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resources.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor),
              itemBuilder: (context, index) => _ResourceRow(resource: resources[index]),
            ),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text, {this.align = TextAlign.left});

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.3,
          ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ResourceAvatar(resource: resource),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        resource.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resource.mobileNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 4, child: ResourceStatusToggle(resource: resource)),
          Expanded(flex: 3, child: ResourceNotesField(resource: resource)),
          SizedBox(width: 56, child: Center(child: ResourceCycleButton(resource: resource))),
        ],
      ),
    );
  }
}
