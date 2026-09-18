import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/resource_list_provider.dart';
import 'resource_card.dart';
import 'resource_list_empty_state.dart';

/// Tablet (600–1024px) compact 2-column grid.
class ResourceGridView extends ConsumerWidget {
  const ResourceGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(filteredResourcesProvider);
    if (resources.isEmpty) return const ResourceListEmptyState();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) => ResourceCard(resource: resources[index], dense: true),
    );
  }
}
