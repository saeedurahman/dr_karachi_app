import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacy_app/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.dmSansTextTheme();
    final headerFont = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
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
          fontWeight: FontWeight.w800,
          color: AppColors.structuralNavy,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontFamily: headerFont,
          letterSpacing: -0.025,
          fontWeight: FontWeight.w700,
          color: AppColors.structuralNavy,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontFamily: headerFont,
          letterSpacing: -0.02,
          fontWeight: FontWeight.w700,
          color: AppColors.structuralNavy,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontFamily: headerFont,
          letterSpacing: -0.015,
          fontWeight: FontWeight.w600,
          color: AppColors.structuralNavy,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontFamily: headerFont,
          fontWeight: FontWeight.w600,
          color: AppColors.structuralNavy,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontFamily: headerFont,
          fontWeight: FontWeight.w600,
          color: AppColors.structuralNavy,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontFamily: headerFont,
          fontWeight: FontWeight.w600,
          color: AppColors.structuralNavy,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.onSurface,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
        ),
      ) as TextTheme?,
    );
  }
}
