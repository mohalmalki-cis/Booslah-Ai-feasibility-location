import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _loggedInKey = 'is_logged_in';
  static const String _projectsKey = 'all_projects';

  // Onboarding
  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Login Status
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  // Projects Management

  // Save new project (adds to list)
  static Future<void> saveProject(Map<String, dynamic> projectData) async {
    final prefs = await SharedPreferences.getInstance();

    // Add unique ID and timestamp
    projectData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    projectData['createdAt'] = DateTime.now().toIso8601String();

    // Get existing projects
    final projectsJson = prefs.getString(_projectsKey);
    List<dynamic> projects = [];

    if (projectsJson != null) {
      projects = json.decode(projectsJson) as List<dynamic>;
    }

    // Add new project at the beginning
    projects.insert(0, projectData);

    // Save back
    await prefs.setString(_projectsKey, json.encode(projects));
  }

  // Get all projects
  static Future<List<Map<String, dynamic>>> getAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString(_projectsKey);

    if (projectsJson != null) {
      final List<dynamic> projectsList = json.decode(projectsJson);
      return projectsList.map((p) => p as Map<String, dynamic>).toList();
    }

    return [];
  }

  // Delete project by ID
  static Future<void> deleteProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString(_projectsKey);

    if (projectsJson != null) {
      List<dynamic> projects = json.decode(projectsJson) as List<dynamic>;
      projects.removeWhere((p) => p['id'] == projectId);
      await prefs.setString(_projectsKey, json.encode(projects));
    }
  }

  // Get last project (most recent)
  static Future<Map<String, dynamic>?> getLastProject() async {
    final projects = await getAllProjects();
    if (projects.isNotEmpty) {
      return projects.first;
    }
    return null;
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Analysis Factor Weights ──────────────────────────────────────────────
  // المفتاح لحفظ الأوزان المخصصة
  static const String _weightsKey = 'analysis_weights';

  // الأوزان الافتراضية (مجموعها = 100)
  static const Map<String, double> defaultWeights = {
    'budget':     25.0,
    'area':       20.0,
    'services':   20.0,
    'audience':   15.0,
    'location':   20.0,
  };

  /// حفظ الأوزان المخصصة
  static Future<void> saveWeights(Map<String, double> weights) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = weights.map(
      (k, v) => MapEntry(k, v),
    );
    await prefs.setString(_weightsKey, json.encode(toSave));
  }

  /// استرجاع الأوزان (إن لم توجد يُرجع الافتراضية)
  static Future<Map<String, double>> getWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weightsKey);
    if (raw == null) return Map.from(defaultWeights);

    final Map<String, dynamic> decoded = json.decode(raw);
    return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  // ─── User Profile ─────────────────────────────────────────────────────────
  static const String _profileKey = 'user_profile';

  static Future<void> saveProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile));
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) {
      return {
        'name': 'تركي الفوزان',
        'email': 'Turki@ksu.com',
        'phone': '+966 50 123 4567',
      };
    }
    final Map<String, dynamic> decoded = json.decode(raw);
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }
}
