import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_mode_provider.dart';

/// Light/dark mode toggle shown in the header.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    return IconButton.outlined(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
    );
  }
}
