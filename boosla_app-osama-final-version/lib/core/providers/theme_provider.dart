import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مزوّد الثيم — يحفظ وضع الدارك/اللايت في SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const String _key = 'setting_dark_mode';

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(_key) ?? false;
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  Future<void> setDark(bool dark) async {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }
}
