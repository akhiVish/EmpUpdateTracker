import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/resource.dart';

/// Initials avatar with a color derived from the resource's name, so each
/// person keeps a stable, recognizable color across the dashboard.
class ResourceAvatar extends StatelessWidget {
  const ResourceAvatar({super.key, required this.resource, this.radius = 20});

  final Resource resource;
  final double radius;

  static const List<Color> _palette = [
    AppColors.indigo,
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  Color _colorFor(String name) {
    final index = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % _palette.length;
    return _palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(resource.name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        resource.initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }
}
