import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/nav_provider.dart';

/// Mobile bottom app bar navigation.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTabProvider);

    return NavigationBar(
      selectedIndex: AppTab.values.indexOf(selected),
      onDestinationSelected: (index) => ref.read(selectedTabProvider.notifier).set(AppTab.values[index]),
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Resources'),
        NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
      ],
    );
  }
}
