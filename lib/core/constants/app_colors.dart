import 'package:flutter/material.dart';

/// Evergo Brand Color Palette
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1E6EFF);
  static const Color primaryLight = Color(0xFF5291FF);
  static const Color primaryDark = Color(0xFF0050D0);

  // Accent
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentLight = Color(0xFF4DFFD8);
  static const Color accentDark = Color(0xFF009E7E);

  // Warning / Status
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4C4C);
  static const Color success = Color(0xFF00C853);
  static const Color info = Color(0xFF00B4FF);

  // Dark Theme Backgrounds
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF141828);
  static const Color cardDark = Color(0xFF1C2235);
  static const Color cardDark2 = Color(0xFF222840);
  static const Color dividerDark = Color(0xFF2A3050);

  // Light Theme Backgrounds
  static const Color backgroundLight = Color(0xFFF0F4FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE0E8FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B96B0);
  static const Color textMuted = Color(0xFF4A5270);
  static const Color textDark = Color(0xFF0A0E1A);
  static const Color textDarkSecondary = Color(0xFF4A5580);

  // Map Colors
  static const Color mapRoute = Color(0xFF1E6EFF);
  static const Color busOnline = Color(0xFF00C853);
  static const Color busOffline = Color(0xFFFF4C4C);
  static const Color busIdle = Color(0xFFFFB800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E6EFF), Color(0xFF00D4AA)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF141828)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C2235), Color(0xFF222840)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF1E6EFF)],
  );

  // Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
