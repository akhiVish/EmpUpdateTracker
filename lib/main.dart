import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/resource_tracker/presentation/providers/theme_mode_provider.dart';
import 'features/resource_tracker/presentation/screens/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ResourceTrackerApp()));
}

class ResourceTrackerApp extends ConsumerWidget {
  const ResourceTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Daily Resource Activity Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: authState.when(
        data: (user) => user == null ? const LoginScreen() : const DashboardScreen(),
        loading: () => const _SplashScreen(),
        error: (error, stack) => const _SplashScreen(),
      ),
    );
  }
}

/// Shown only for the brief moment while Firebase resolves whether a
/// session is already active.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
