import 'package:flutter/material.dart';class AppColors {
  // 2026 Premium Aura Palette
  static const Color primary = Color(0xFF030213);    // Space Black
  static const Color primaryLight = Color(0xFF1E1B4B); // Deep Indigo
  static const Color secondary = Color(0xFF6366F1);  // Electric Indigo
  static const Color accent = Color(0xFF00D4FF);     // Electric Cyan
  static const Color cyan = Color(0xFF00D4FF);       // Alias for compatibility
  static const Color tertiary = Color(0xFFD433FF);   // Neon Purple

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color card = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF030213), Color(0xFF1E1B4B)];
  static const List<Color> accentGradient = [Color(0xFF00D4FF), Color(0xFF6366F1)];
  static const List<Color> auraGradient = [Color(0xFF6366F1), Color(0xFFD433FF)];

  // Glassmorphism Tokens
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Functional Neutrals
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
}