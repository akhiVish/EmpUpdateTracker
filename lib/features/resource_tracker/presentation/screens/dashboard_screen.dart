import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../providers/nav_provider.dart';
import '../widgets/layout/app_bottom_nav.dart';
import '../widgets/layout/app_side_nav.dart';
import 'dashboard_tab_content.dart';
import 'reports_screen.dart';
import 'resources_screen.dart';

/// The app shell: a collapsible desktop side nav, a tablet drawer, or a
/// mobile bottom bar, based on the available width — hosting whichever
/// tab ([AppTab]) is currently selected.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = AppBreakpoints.deviceTypeFor(constraints.maxWidth);
        switch (deviceType) {
          case DeviceType.desktop:
            return Scaffold(
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppSideNav(),
                  const Expanded(child: _TabContent()),
                ],
              ),
            );
          case DeviceType.tablet:
            return Scaffold(
              appBar: const _AppTabAppBar(),
              drawer: const Drawer(child: AppSideNav()),
              body: const _TabContent(),
            );
          case DeviceType.mobile:
            return Scaffold(
              appBar: const _AppTabAppBar(),
              body: const _TabContent(),
              bottomNavigationBar: const AppBottomNav(),
            );
        }
      },
    );
  }
}

class _AppTabAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppTabAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    return AppBar(
      title: Text(tab == AppTab.dashboard ? 'ResourceTrack' : tab.label, style: const TextStyle(fontWeight: FontWeight.w800)),
      actions: const [Padding(padding: EdgeInsets.only(right: 12), child: SignOutButton())],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TabContent extends ConsumerWidget {
  const _TabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    return switch (tab) {
      AppTab.dashboard => const DashboardTabContent(),
      AppTab.resources => const ResourcesScreen(),
      AppTab.reports => const ReportsScreen(),
    };
  }
}
