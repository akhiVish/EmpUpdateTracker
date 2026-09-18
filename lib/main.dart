import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/resource_tracker/presentation/providers/theme_mode_provider.dart';
import 'features/resource_tracker/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: ResourceTrackerApp()));
}

class ResourceTrackerApp extends ConsumerWidget {
  const ResourceTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Daily Resource Activity Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}
