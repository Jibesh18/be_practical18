import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'spacing.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.fontFamily,

      // Setting platform to iOS globally for premium bouncing physics
      platform: TargetPlatform.iOS,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onSurface: AppColors.primary,
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: AppColors.primary),
        headlineMedium: AppTextStyles.heading.copyWith(color: AppColors.primary),
        titleMedium: AppTextStyles.subheading.copyWith(color: AppColors.primary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.primary),
        labelLarge: AppTextStyles.label.copyWith(color: AppColors.primary),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.muted),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading.copyWith(color: AppColors.primary, fontSize: 20),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // FIXED: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}