import 'package:flutter/material.dart';

class AppColors {
  // Core Brand Swatches
  static const Color primaryAccent = Color(0xFFC92A2A); // Clinical deep red
  static const Color structuralNavy = Color(0xFF0B132B); // Primary header and structure
  static const Color diagnosticCyan = Color(0xFF0284C7); // Diagnostics
  static const Color canvasBase = Color(0xFFF8FAFC); // Sterile canvas

  // Full Material Theme Palette extracted from Design System
  static const Color primary = Color(0xFFA50915);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFC92A2A);
  static const Color onPrimaryContainer = Color(0xFFFFE5E2);

  static const Color secondary = Color(0xFF565D79);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD8DEFF);
  static const Color onSecondaryContainer = Color(0xFF5A627E);

  static const Color tertiary = Color(0xFF005684);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF006FA9);
  static const Color onTertiaryContainer = Color(0xFFDBECFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color onSurface = Color(0xFF0B1C30);
  
  static const Color outline = Color(0xFF8F706C);
  static const Color outlineVariant = Color(0xFFE4BEBA);
  static const Color surfaceVariant = Color(0xFFD3E4FE);
  static const Color onSurfaceVariant = Color(0xFF5B403D);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);
  
  // Custom Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444), // Highlight
      Color(0xFFC92A2A), // Accent
    ],
  );
}
