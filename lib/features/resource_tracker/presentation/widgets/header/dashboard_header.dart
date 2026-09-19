import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../holidays/holidays_button.dart';
import 'add_resource_dialog.dart';
import 'date_navigator.dart';
import 'resource_search_bar.dart';
import 'theme_toggle_button.dart';

/// Page title, date navigator, search bar and the "+ Add Resource" action.
/// Reflows via [Wrap] so it stays usable from mobile up to ultrawide. The
/// Add Resource action is hidden on mobile here — it's already reachable
/// from the Resources tab, and keeping it off the Dashboard keeps that
/// screen focused on today's status instead of roster management.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = deviceType == DeviceType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Daily Resource Activity Tracker',
                style: (isMobile ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall)
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            if (isMobile) ...[
              const HolidaysButton(compact: true),
              const SizedBox(width: 8),
            ],
            const ThemeToggleButton(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Track who has shared their end-of-day update, who is on leave, and who still needs a nudge.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DateNavigator(),
              const SizedBox(height: 12),
              const ResourceSearchBar(maxWidth: double.infinity),
            ],
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const DateNavigator(),
              const ResourceSearchBar(maxWidth: 320),
              ElevatedButton.icon(
                onPressed: () => AddResourceDialog.show(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Resource'),
              ),
              const HolidaysButton(),
            ],
          ),
      ],
    );
  }
}
