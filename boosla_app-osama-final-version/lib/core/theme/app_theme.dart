import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.white,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.primary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: AppTextStyles.headingMedium,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headingLarge,
      headlineMedium: AppTextStyles.headingMedium,
      headlineSmall: AppTextStyles.headingSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.caption,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
  );

  // ─── الثيم الداكن ───────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF0F172A),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF1E3A5F),
      surface: Color(0xFF1E293B),
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE2E8F0),
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF3B82F6)),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // AppTextStyles بدون ألوان → Flutter يطبق onSurface تلقائياً (0xFFE2E8F0)
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   height: 1.2, color: Color(0xFFE2E8F0)),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,   height: 1.2, color: Color(0xFFE2E8F0)),
      displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold,   height: 1.2, color: Color(0xFFE2E8F0)),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,   height: 1.3, color: Color(0xFFE2E8F0)),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600,   height: 1.3, color: Color(0xFFE2E8F0)),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,   height: 1.3, color: Color(0xFFE2E8F0)),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.normal,  height: 1.5, color: Color(0xFFE2E8F0)),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.normal,  height: 1.5, color: Color(0xFFE2E8F0)),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.normal,  height: 1.5, color: Color(0xFF94A3B8)),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500,    height: 1.4, color: Color(0xFFE2E8F0)),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.normal,  height: 1.4, color: Color(0xFF94A3B8)),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.label.copyWith(color: const Color(0xFF94A3B8)),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF64748B)),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button.copyWith(color: const Color(0xFF3B82F6)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),

    iconTheme: const IconThemeData(color: Color(0xFF3B82F6), size: 24),
  );
}
