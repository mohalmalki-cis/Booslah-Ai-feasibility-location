import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

/// خدمة المشاريع — الأسبوع العاشر
/// تتعامل مع Firestore لحفظ واسترجاع وحذف مشاريع المستخدم
///
/// هيكل Firestore:
///   users/{uid}/projects/{projectId}

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── مرجع مجموعة مشاريع المستخدم ─────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _projectsRef(String uid) {
    return _db.collection('users').doc(uid).collection('projects');
  }

  // ─── جلب المشاريع (مرة واحدة) ────────────────────────────────────────────
  Future<List<ProjectModel>> getProjects(String uid) async {
    final snapshot = await _projectsRef(
      uid,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
  }

  // ─── Stream مشاريع المستخدم (مباشر) ──────────────────────────────────────
  Stream<List<ProjectModel>> getProjectsStream(String uid) {
    return _projectsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ─── حفظ مشروع جديد ──────────────────────────────────────────────────────
  Future<ProjectModel> saveProject({
    required String uid,
    required Map<String, dynamic> projectData,
  }) async {
    // إنشاء مرجع جديد للحصول على ID تلقائي
    final docRef = _projectsRef(uid).doc();

    // حساب التقييم تلقائياً إذا لم يكن موجوداً أو كان صفراً
    final rawScore = projectData['score'];
    final calculatedScore = (rawScore == null || rawScore == 0)
        ? _calculateScore(projectData)
        : (rawScore as num).toDouble();

    final project = ProjectModel.fromMap({
      ...projectData,
      'id': docRef.id,
      'score': calculatedScore,
      'createdAt': projectData['createdAt'] ?? DateTime.now().toIso8601String(),
    }, uid);

    await docRef.set(project.toFirestore());
    return project;
  }

  // ─── حساب التقييم الأولي ──────────────────────────────────────────────────
  /// يدعم القيم الإنجليزية الجديدة (High/Medium/Low, Large/Medium/Small)
  /// والقيم العربية القديمة للمشاريع السابقة
  double _calculateScore(Map<String, dynamic> p) {
    double score = 60.0;
    final budget = p['budget'] as String? ?? '';
    final area = p['area'] as String? ?? '';

    // الميزانية
    if (budget == 'High' ||
        budget.contains('أكثر') ||
        budget.contains('1,000,000')) {
      score += 12;
    } else if (budget == 'Medium' || budget.contains('500'))
      score += 8;
    else if (budget == 'Low' || budget.contains('200'))
      score += 5;

    // المساحة
    if (area == 'Large' ||
        area.contains('كبير') ||
        area.contains('400') ||
        area.contains('200')) {
      score += 8;
    } else if (area == 'Medium' || area.contains('100'))
      score += 5;

    // الخصائص
    if (p['is24Hours'] == true) score += 3;
    if (p['hasInternalSeating'] == true) score += 3;
    if (p['hasCarService'] == true) score += 3;
    if (p['hasExternalTables'] == true) score += 2;
    if (p['hasParking'] == true) score += 2;

    // التوصيل
    if (p['dependsOnDelivery'] == 'High') {
      score += 3;
    } else if (p['dependsOnDelivery'] == 'Medium')
      score += 2;

    // عمر المشروع
    final age = p['shop_age'] as int?;
    if (age != null) {
      if (age >= 5) {
        score += 3;
      } else if (age >= 2)
        score += 1;
    }

    return score.clamp(0.0, 100.0);
  }

  // ─── حذف مشروع ───────────────────────────────────────────────────────────
  Future<void> deleteProject({
    required String uid,
    required String projectId,
  }) async {
    await _projectsRef(uid).doc(projectId).delete();
  }

  // ─── تحديث نتيجة المشروع ─────────────────────────────────────────────────
  Future<void> updateScore({
    required String uid,
    required String projectId,
    required double score,
  }) async {
    await _projectsRef(uid).doc(projectId).update({'score': score});
  }

  // ─── جلب آخر مشروع ───────────────────────────────────────────────────────
  Future<ProjectModel?> getLastProject(String uid) async {
    final snapshot = await _projectsRef(
      uid,
    ).orderBy('createdAt', descending: true).limit(1).get();

    if (snapshot.docs.isEmpty) return null;
    return ProjectModel.fromFirestore(snapshot.docs.first);
  }

  // ─── Mock Data للتطوير ───────────────────────────────────────────────────
  /// يضيف مشاريع تجريبية للمستخدم إذا لم يكن عنده أي مشاريع
  Future<void> seedMockProjects(String uid) async {
    final existing = await getProjects(uid);
    if (existing.isNotEmpty) return; // لا تضيف إذا فيه مشاريع

    final mockProjects = [
      {
        'businessId': 'cafe_001',
        'businessType': 'مقهى',
        'businessEmoji': '☕',
        'projectName': 'مقهى F1',
        'is24Hours': false,
        'hasInternalSeating': true,
        'hasCarService': false,
        'hasExternalTables': true,
        'dependsOnDelivery': 'Low',
        'targetAudience': 'Youth',
        'area': '100-200 م²',
        'budget': '200,000 - 500,000 ريال',
        'nearbyLandmarks': 'بجانب جامعة الملك سعود',
        'cafeType': 'مقهى تخصصي',
        'score': 82.0,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
      {
        'businessId': 'restaurant_001',
        'businessType': 'مطعم',
        'businessEmoji': '🍔',
        'projectName': 'مطعم M2',
        'is24Hours': false,
        'hasInternalSeating': true,
        'hasCarService': true,
        'hasExternalTables': false,
        'dependsOnDelivery': 'High',
        'targetAudience': 'Families',
        'area': '200-400 م²',
        'budget': '500,000 - 1,000,000 ريال',
        'nearbyLandmarks': 'حي الروضة، جدة',
        'restaurantType': 'مطعم وجبات سريعة',
        'score': 75.0,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
      },
      {
        'businessId': 'cafe_002',
        'businessType': 'مقهى',
        'businessEmoji': '☕',
        'projectName': 'مقهى Sep',
        'is24Hours': true,
        'hasInternalSeating': true,
        'hasCarService': false,
        'hasExternalTables': false,
        'dependsOnDelivery': 'Medium',
        'targetAudience': 'Employees',
        'area': '50-100 م²',
        'budget': '100,000 - 200,000 ريال',
        'nearbyLandmarks': 'حي الفيصلية، الدمام',
        'cafeType': 'مقهى عادي',
        'score': 68.0,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 14))
            .toIso8601String(),
      },
    ];

    for (final data in mockProjects) {
      await saveProject(uid: uid, projectData: data);
    }
  }
}
