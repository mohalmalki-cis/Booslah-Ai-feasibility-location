import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ألوان تكيفية — تقرأ الثيم الحالي وتُعيد اللون المناسب
/// الاستخدام: context.cs.card بدلاً من AppColors.white
class AppColorSchemeX {
  final bool isDark;

  const AppColorSchemeX({required this.isDark});

  // ─── الخلفيات ──────────────────────────────────────────────────────────────
  Color get scaffold => isDark ? const Color(0xFF0F172A) : AppColors.background;
  Color get card     => isDark ? const Color(0xFF1E293B) : AppColors.white;
  Color get cardAlt  => isDark ? const Color(0xFF263347) : const Color(0xFFF8FAFC);

  // ─── النصوص ────────────────────────────────────────────────────────────────
  Color get textPrimary   => isDark ? const Color(0xFFE2E8F0) : AppColors.textPrimary;
  Color get textSecondary => isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
  Color get textLight     => isDark ? const Color(0xFF64748B) : AppColors.textLight;

  // ─── الحدود ────────────────────────────────────────────────────────────────
  Color get border      => isDark ? const Color(0xFF334155) : AppColors.border;
  Color get borderLight => isDark ? const Color(0xFF1E293B) : AppColors.borderLight;

  // ─── الظل ──────────────────────────────────────────────────────────────────
  Color get shadow => isDark ? const Color(0x40000000) : AppColors.shadow;

  // ─── الألوان التكيفية للعناوين والأكسنت ───────────────────────────────────────
  /// لون العناوين الرئيسية — داكن في الوضع الفاتح، أزرق فاتح في الداكن
  Color get primaryText => isDark ? const Color(0xFF93C5FD) : AppColors.primary;
  /// للأيقونات والعناصر الثابتة التي تظهر على خلفيات ملونة
  Color get primary   => AppColors.primary;
  Color get secondary => isDark ? const Color(0xFF1E3A5F) : AppColors.secondary;
  Color get success   => AppColors.success;
  Color get error     => AppColors.error;
  Color get warning   => AppColors.warning;
  Color get info      => AppColors.info;

  // ─── الأيقونة والـ overlay ──────────────────────────────────────────────────
  Color get iconBg => isDark
      ? AppColors.primary.withOpacity(0.3)
      : AppColors.secondary.withOpacity(0.3);

  Color get overlayDark => isDark
      ? Colors.black.withOpacity(0.5)
      : Colors.black.withOpacity(0.25);
}

/// Extension على BuildContext لسهولة الوصول
extension AppColorSchemeContext on BuildContext {
  AppColorSchemeX get cs => AppColorSchemeX(
        isDark: Theme.of(this).brightness == Brightness.dark,
      );
}
