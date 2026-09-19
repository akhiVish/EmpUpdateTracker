import 'package:flutter/material.dart';

import 'holidays_dialog.dart';

/// Opens the holidays manager. [compact] renders an icon-only button for
/// tight layouts (mobile title row).
class HolidaysButton extends StatelessWidget {
  const HolidaysButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton.outlined(
        tooltip: 'Holidays',
        icon: const Icon(Icons.event_busy_rounded),
        onPressed: () => HolidaysDialog.show(context),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => HolidaysDialog.show(context),
      icon: const Icon(Icons.event_busy_rounded, size: 18),
      label: const Text('Holidays'),
    );
  }
}
