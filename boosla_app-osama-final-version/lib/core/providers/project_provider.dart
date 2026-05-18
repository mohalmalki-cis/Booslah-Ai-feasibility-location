import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

/// حالات ProjectProvider
enum ProjectStatus { initial, loading, loaded, error }

/// Project Provider — الأسبوع العاشر
/// يُدير قائمة مشاريع المستخدم ويربطها بـ Firestore

class ProjectProvider extends ChangeNotifier {
  final ProjectService _service = ProjectService();

  ProjectStatus _status = ProjectStatus.initial;
  List<ProjectModel> _projects = [];
  String? _errorMessage;
  String? _currentUid;

  // ─── Getters ──────────────────────────────────────────────────────────────
  ProjectStatus get status => _status;
  List<ProjectModel> get projects => _projects;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProjectStatus.loading;
  ProjectModel? get lastProject => _projects.isNotEmpty ? _projects.first : null;

  // ─── تحميل مشاريع المستخدم ────────────────────────────────────────────────
  Future<void> loadProjects(String uid) async {
    if (_currentUid == uid && _status == ProjectStatus.loaded) return;

    _currentUid = uid;
    _status = ProjectStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mock Data تُضاف مرة واحدة فقط (أول تشغيل) — نتجنب استدعاءها كل مرة
      final prefs = await SharedPreferences.getInstance();
      final seeded = prefs.getBool('mock_seeded_$uid') ?? false;
      if (!seeded) {
        await _service.seedMockProjects(uid);
        await prefs.setBool('mock_seeded_$uid', true);
      }

      _projects = await _service.getProjects(uid);
      _status = ProjectStatus.loaded;
    } catch (e) {
      _status = ProjectStatus.error;
      _errorMessage = 'تعذّر تحميل المشاريع: $e';
    }

    notifyListeners();
  }

  // ─── إعادة تحميل ─────────────────────────────────────────────────────────
  Future<void> refresh() async {
    if (_currentUid == null) return;
    final uid = _currentUid!; // نحفظه قبل تصفيره
    _currentUid = null; // لإجبار إعادة التحميل
    await loadProjects(uid);
  }

  // ─── حفظ مشروع جديد ──────────────────────────────────────────────────────
  Future<bool> saveProject({
    required String uid,
    required Map<String, dynamic> projectData,
  }) async {
    try {
      final project = await _service.saveProject(
        uid: uid,
        projectData: projectData,
      );
      _projects.insert(0, project); // يضيف في الأول (الأحدث أولاً)
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'تعذّر حفظ المشروع: $e';
      notifyListeners();
      return false;
    }
  }

  // ─── حذف مشروع ───────────────────────────────────────────────────────────
  Future<bool> deleteProject({
    required String uid,
    required String projectId,
  }) async {
    try {
      await _service.deleteProject(uid: uid, projectId: projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'تعذّر حذف المشروع: $e';
      notifyListeners();
      return false;
    }
  }

  // ─── تحديث النتيجة ───────────────────────────────────────────────────────
  Future<void> updateScore({
    required String uid,
    required String projectId,
    required double score,
  }) async {
    try {
      await _service.updateScore(
        uid: uid,
        projectId: projectId,
        score: score,
      );
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(score: score);
        notifyListeners();
      }
    } catch (_) {}
  }

  // ─── مسح عند تسجيل الخروج ────────────────────────────────────────────────
  void clear() {
    _projects = [];
    _status = ProjectStatus.initial;
    _errorMessage = null;
    _currentUid = null;
    notifyListeners();
  }
}
