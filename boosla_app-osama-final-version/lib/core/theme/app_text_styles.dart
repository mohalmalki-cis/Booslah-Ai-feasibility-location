import 'package:flutter/material.dart';

/// الألوان محذوفة من هنا عمداً — يرثها الـ Widget من DefaultTextStyle
/// اللي Flutter يضبطه تلقائياً بناءً على darkTheme/lightTheme.
/// أي widget يحتاج لون صريح يستخدم .copyWith(color: context.cs.textPrimary)
class AppTextStyles {
  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Button Styles (الأبيض يبقى ثابت لأن الأزرار دايماً على خلفية ملونة)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Caption & Label
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}
