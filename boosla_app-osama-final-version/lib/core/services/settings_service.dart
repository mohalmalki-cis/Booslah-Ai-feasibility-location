import 'package:shared_preferences/shared_preferences.dart';

/// SettingsService — الأسبوع الرابع عشر
/// ─────────────────────────────────────────────────────────────────────────────
/// يُدير إعدادات التطبيق عبر SharedPreferences.
/// يُستخدم في settings_screen.dart بدل حفظ الحالة محلياً.
///
/// الاستخدام:
///   final enabled = await SettingsService.isNotificationsEnabled();
///   await SettingsService.setNotifications(true);

class SettingsService {
  SettingsService._();

  // ─── المفاتيح ─────────────────────────────────────────────────────────────
  static const String _keyNotifications = 'setting_notifications';
  static const String _keyLanguage      = 'setting_language';
  static const String _keyOnboarding    = 'has_seen_onboarding';

  // ─── الإشعارات ────────────────────────────────────────────────────────────

  /// هل الإشعارات مفعّلة؟ (الافتراضي: مفعّلة)
  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  /// تفعيل / تعطيل الإشعارات
  static Future<void> setNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  // ─── اللغة ────────────────────────────────────────────────────────────────

  /// اللغة الحالية (الافتراضي: 'ar')
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'ar';
  }

  /// تغيير اللغة
  static Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, langCode);
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
  }

  // ─── إعادة تعيين كل الإعدادات ────────────────────────────────────────────

  /// يعيد كل الإعدادات للقيم الافتراضية (لا يمسّ بيانات المستخدم أو المشاريع)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyLanguage);
  }
}
