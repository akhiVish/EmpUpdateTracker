import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/resource.dart';
import '../../providers/resource_list_provider.dart';

/// Confirmation dialog before permanently removing a resource from the
/// roster (every day, past and future).
class DeleteResourceDialog {
  static Future<void> show(BuildContext context, WidgetRef ref, Resource resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove resource?'),
        content: Text(
          '${resource.name} will be removed from the roster for every day, including past history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.crimson),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(resourceListProvider.notifier).deleteResource(resource.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${resource.name} removed')),
    );
  }
}
