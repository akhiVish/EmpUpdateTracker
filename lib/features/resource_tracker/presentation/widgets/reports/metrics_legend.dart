import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Color-coded legend shared by the trend chart and the snapshot donut.
class MetricsLegend extends StatelessWidget {
  const MetricsLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(color: AppColors.emerald, label: 'Updated'),
        _LegendItem(color: AppColors.amber, label: 'On Leave'),
        _LegendItem(color: AppColors.crimson, label: 'Not Updated'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}
