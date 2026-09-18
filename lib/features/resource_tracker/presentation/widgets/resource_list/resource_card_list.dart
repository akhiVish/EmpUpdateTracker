import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/resource_status.dart';
import '../../providers/resource_list_provider.dart';
import 'resource_card.dart';
import 'resource_list_empty_state.dart';

/// Mobile (<= 600px) vertical card list. Swipe right marks a resource
/// Updated, swipe left marks them On Leave — the card itself never leaves
/// the list, only its status changes.
class ResourceCardList extends ConsumerWidget {
  const ResourceCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(filteredResourcesProvider);
    if (resources.isEmpty) return const ResourceListEmptyState();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Dismissible(
          key: ValueKey(resource.id),
          direction: DismissDirection.horizontal,
          background: const _SwipeBackground(
            alignment: Alignment.centerLeft,
            color: AppColors.emerald,
            icon: Icons.check_circle_rounded,
            label: 'Updated',
          ),
          secondaryBackground: const _SwipeBackground(
            alignment: Alignment.centerRight,
            color: AppColors.amber,
            icon: Icons.wb_sunny_rounded,
            label: 'On Leave',
          ),
          confirmDismiss: (direction) async {
            final notifier = ref.read(resourceListProvider.notifier);
            if (direction == DismissDirection.startToEnd) {
              await notifier.updateStatus(resource.id, ResourceStatus.updated);
            } else {
              await notifier.updateStatus(resource.id, ResourceStatus.onLeave);
            }
            return false;
          },
          child: ResourceCard(resource: resource),
        );
      },
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
