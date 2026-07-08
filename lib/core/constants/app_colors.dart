import 'package:flutter/material.dart';

/// Evergo Brand Color Palette
class AppColors {
  AppColors._();

  // Custom brand colors requested by user
  static const Color primary = Color(0xFF5BAF2E);
  static const Color secondary = Color(0xFF8BCF4A);
  static const Color dark = Color(0xFF162425);
  static const Color darkGrey = Color(0xFF2D3A3B);
  static const Color background = Color(0xFFF8FAF8);
  static const Color white = Color(0xFFFFFFFF);

  // Primary Brand Colors
  static const Color primaryLight = Color(0xFF8BCF4A);
  static const Color primaryDark = Color(0xFF4C9325);

  // Accent
  static const Color accent = Color(0xFF5BAF2E);
  static const Color accentLight = Color(0xFF8BCF4A);
  static const Color accentDark = Color(0xFF4C9325);

  // Warning / Status
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4C4C);
  static const Color success = Color(0xFF8BCF4A);
  static const Color info = Color(0xFF00B4FF);

  // Dark Theme Backgrounds (Mapped to match off-white / white light theme)
  static const Color backgroundDark = Color(0xFFF8FAF8);
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFFFFFFFF);
  static const Color cardDark2 = Color(0xFFFFFFFF);
  static const Color dividerDark = Color(0x1A2D3A3B);

  // Light Theme Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAF8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0x1A2D3A3B);

  // Text Colors
  static const Color textPrimary = Color(0xFF162425);
  static const Color textSecondary = Color(0xFF2D3A3B);
  static const Color textMuted = Color(0x992D3A3B);
  static const Color textDark = Color(0xFF162425);
  static const Color textDarkSecondary = Color(0xFF2D3A3B);

  // Map Colors
  static const Color mapRoute = Color(0xFF5BAF2E);
  static const Color busOnline = Color(0xFF5BAF2E);
  static const Color busOffline = Color(0xFFFF4C4C);
  static const Color busIdle = Color(0xFFFFB800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5BAF2E), Color(0xFF8BCF4A)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAF8), Color(0xFFFFFFFF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8BCF4A), Color(0xFF5BAF2E)],
  );

  // Glassmorphism
  static const Color glassBackground = Color(0x1A162425);
  static const Color glassBorder = Color(0x33162425);

  // Subtle shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF162425).withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
