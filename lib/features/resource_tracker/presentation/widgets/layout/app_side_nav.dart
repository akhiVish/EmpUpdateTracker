import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../providers/nav_provider.dart';

class _NavItem {
  const _NavItem(this.tab, this.icon);
  final AppTab tab;
  final IconData icon;
}

const _navItems = [
  _NavItem(AppTab.dashboard, Icons.dashboard_rounded),
  _NavItem(AppTab.resources, Icons.groups_rounded),
  _NavItem(AppTab.reports, Icons.bar_chart_rounded),
];

/// Persistent, collapsible desktop side navigation.
class AppSideNav extends ConsumerStatefulWidget {
  const AppSideNav({super.key});

  @override
  ConsumerState<AppSideNav> createState() => _AppSideNavState();
}

class _AppSideNavState extends ConsumerState<AppSideNav> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = _collapsed ? 76.0 : 232.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.checklist_rtl_rounded, color: Colors.white, size: 20),
                ),
                if (!_collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ResourceTrack',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (final item in _navItems) _buildItem(context, item),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: IconButton(
              tooltip: _collapsed ? 'Expand' : 'Collapse',
              icon: Icon(_collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
              onPressed: () => setState(() => _collapsed = !_collapsed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _NavItem item) {
    final theme = Theme.of(context);
    final selected = ref.watch(selectedTabProvider) == item.tab;
    final color = selected ? AppColors.indigo : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? AppColors.indigo.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            ref.read(selectedTabProvider.notifier).set(item.tab);
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold != null && scaffold.hasDrawer && scaffold.isDrawerOpen) {
              scaffold.closeDrawer();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: color),
                if (!_collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.tab.label,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
