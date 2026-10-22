import 'package:flutter/material.dart' as material;
import 'app_colors.dart';

class AppTheme {
  static const String bodyFont = 'DM Sans';
  static const String headerFont = 'Plus Jakarta Sans';

  static material.ThemeData get lightTheme {
    const material.TextTheme baseTextTheme = material.TextTheme(
      bodyLarge: material.TextStyle(fontFamily: bodyFont),
      bodyMedium: material.TextStyle(fontFamily: bodyFont),
      bodySmall: material.TextStyle(fontFamily: bodyFont),
      labelLarge: material.TextStyle(fontFamily: bodyFont),
      labelMedium: material.TextStyle(fontFamily: bodyFont),
      labelSmall: material.TextStyle(fontFamily: bodyFont),
      titleLarge: material.TextStyle(fontFamily: headerFont),
      titleMedium: material.TextStyle(fontFamily: headerFont),
      titleSmall: material.TextStyle(fontFamily: headerFont),
    );

    return material.ThemeData(
      useMaterial3: true,
      colorScheme: const material.ColorScheme(
        brightness: material.Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.canvasBase,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
            fontFamily: headerFont,
            letterSpacing: -0.03,
            fontWeight: material.FontWeight.w800,
            color: AppColors.structuralNavy),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
            fontFamily: headerFont,
            letterSpacing: -0.025,
            fontWeight: material.FontWeight.w700,
            color: AppColors.structuralNavy),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
            fontFamily: headerFont,
            letterSpacing: -0.02,
            fontWeight: material.FontWeight.w700,
            color: AppColors.structuralNavy),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            fontFamily: headerFont,
            letterSpacing: -0.015,
            fontWeight: material.FontWeight.w600,
            color: AppColors.structuralNavy),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontFamily: headerFont,
            fontWeight: material.FontWeight.w600,
            color: AppColors.structuralNavy),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontFamily: headerFont,
            fontWeight: material.FontWeight.w600,
            color: AppColors.structuralNavy),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontFamily: headerFont,
            fontWeight: material.FontWeight.w600,
            color: AppColors.structuralNavy),
        bodyLarge:
            baseTextTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
        bodyMedium:
            baseTextTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}
