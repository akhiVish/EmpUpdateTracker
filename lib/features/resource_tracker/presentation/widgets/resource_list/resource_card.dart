import 'package:flutter/material.dart';

import '../../../domain/entities/resource.dart';
import 'resource_avatar.dart';
import 'resource_cycle_button.dart';
import 'resource_notes_field.dart';
import 'resource_status_toggle.dart';
import 'status_style.dart';

/// Card representation of a resource, used by the tablet grid and the
/// mobile vertical list.
class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource, this.dense = false});

  final Resource resource;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ResourceAvatar(resource: resource, radius: 18),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resource.mobileNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ResourceCycleButton(resource: resource),
              ],
            ),
            const SizedBox(height: 12),
            ResourceStatusToggle(resource: resource, dense: dense),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: resource.status.color.withValues(alpha: 0.15)),
              ),
              child: ResourceNotesField(resource: resource, maxLines: dense ? 1 : 2),
            ),
          ],
        ),
      ),
    );
  }
}
