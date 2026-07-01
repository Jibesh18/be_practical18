import 'package:flutter/material.dart';

class AppColors {
  // ── Modern Professional (Slate & Indigo) ────────────────────────────────
  // This palette is inspired by modern tools like Linear and GitHub.
  static const Color primary        = Color(0xFF6366F1); // Indigo 500 (Clean, Trustworthy)
  static const Color primaryLight   = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark    = Color(0xFF4F46E5); // Indigo 600
  static const Color primarySurface = Color(0xFFEEF2FF); // Indigo 50

  // ── Accents ──────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color accent    = Color(0xFFF43F5E); // Rose 500 (Use sparingly)

  // ── Light Theme (Clean Zinc) ─────────────────────────────────────────────
  static const Color lightBg            = Color(0xFFFAFAFA); 
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightCard          = Color(0xFFFFFFFF);
  static const Color lightTextPrimary   = Color(0xFF09090B); // Zinc 950
  static const Color lightTextSecondary = Color(0xFF52525B); // Zinc 600
  static const Color lightTextTertiary  = Color(0xFFA1A1AA); // Zinc 400
  static const Color lightBorder        = Color(0xFFE4E4E7); // Zinc 200
  static const Color lightDivider       = Color(0xFFF4F4F5); // Zinc 100

  // ── Dark Theme (Deep Zinc / Obsidian) ────────────────────────────────────
  static const Color darkBg            = Color(0xFF09090B); // Zinc 950
  static const Color darkSurface       = Color(0xFF18181B); // Zinc 900
  static const Color darkCard          = Color(0xFF27272A); // Zinc 800
  static const Color darkTextPrimary   = Color(0xFFFAFAFA); // Zinc 50
  static const Color darkTextSecondary = Color(0xFFD4D4D8); // Zinc 300
  static const Color darkTextTertiary  = Color(0xFF71717A); // Zinc 500
  static const Color darkBorder        = Color(0xFF3F3F46); // Zinc 700
  static const Color darkDivider       = Color(0xFF27272A); // Zinc 800

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF10B981);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color error          = Color(0xFFEF4444);
  static const Color info           = Color(0xFF3B82F6);

  // ── Aliases ───────────────────────────────────────────────────────────────
  static const Color background    = lightBg;
  static const Color surface       = lightSurface;
  static const Color textPrimary   = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary  = lightTextTertiary;
  static const Color border        = lightBorder;
}