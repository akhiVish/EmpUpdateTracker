import 'package:flutter/material.dart';

/// Central color palette for the Daily Resource Activity Tracker.
class AppColors {
  AppColors._();

  // Brand
  static const Color slate = Color(0xFF1E293B);
  static const Color indigo = Color(0xFF6366F1);

  // Status accents
  static const Color emerald = Color(0xFF10B981); // Updated
  static const Color amber = Color(0xFFF59E0B); // On Leave
  static const Color crimson = Color(0xFFEF4444); // Not Updated

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightMuted = Color(0xFF64748B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkMuted = Color(0xFF94A3B8);
}
