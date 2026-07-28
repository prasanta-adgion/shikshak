import 'package:flutter/material.dart';

/// Single source of truth for every color in the app.
///
/// Widgets must never hardcode a [Color] — they read from the active
/// [ColorScheme] (built in `AppTheme`) or, for brand gradients and semantic
/// colors, from this class.
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color tertiary = Color(0xFF2E9958);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Light neutrals ───────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAFAFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ── Dark neutrals ────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF151B2E);
  static const Color darkSurfaceVariant = Color(0xFF1E2740);
  static const Color darkBorder = Color(0xFF2A3552);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkNavy = Color(0xFF011B44);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue → indigo, used for teacher-facing hero surfaces.
  static const LinearGradient teacherGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm orange → amber, used for student-facing hero surfaces.
  static const LinearGradient studentGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft page-background wash used behind auth screens (light mode).
  static const LinearGradient lightPageGradient = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC), Color(0xFFFDF4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft page-background wash used behind auth screens (dark mode).
  static const LinearGradient darkPageGradient = LinearGradient(
    colors: [Color(0xFF111633), Color(0xFF0B1120), Color(0xFF1A1033)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
