import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Signs the current user out. [authStateChangesProvider] picks up the
/// change and the app shell swaps back to the login screen automatically.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.outlined(
      tooltip: 'Sign out',
      icon: const Icon(Icons.logout_rounded),
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
    );
  }
}
