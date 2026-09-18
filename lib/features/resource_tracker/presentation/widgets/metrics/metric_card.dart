import 'package:flutter/material.dart';

/// A single stat tile in the analytics banner (Total / Updated / On Leave /
/// Not Updated), color-accented via a soft icon badge and left rule.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    // A Border can't mix per-side colors with a borderRadius, so the
    // colored accent rule is painted separately from the neutral outline.
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
                color: selected ? accentColor.withValues(alpha: 0.06) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  // Flexible (loose), not Expanded: on the mobile 2-column
                  // grid it still bounds the label to prevent overflow, but
                  // on desktop's Wrap layout it lets the card size to its
                  // natural content width instead of stretching to fill
                  // whatever width Wrap happens to offer.
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$value',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: ColoredBox(color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
