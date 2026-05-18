import 'package:flutter/material.dart';
import '../models/comparison_result.dart';

/// خدمة المقارنة بين مشروعين
/// ─────────────────────────────────────────────────────────────────────────────
/// الاستخدام:
///   final result = ComparisonService.instance.compare(projectA, projectB);
///
/// عند ربط الـ AI:
///   استبدل _calculateScore() بالدرجة القادمة من الموديل مباشرة

class ComparisonService {
  ComparisonService._();
  static final ComparisonService instance = ComparisonService._();

  // ألوان المشروعين (ثابتة لتتطابق مع الشاشة)
  static const Color colorA = Color(0xFF112F4E);
  static const Color colorB = Color(0xFF0097A7);

  // ─── الدالة الرئيسية ───────────────────────────────────────────────────────
  ComparisonResult compare(
    Map<String, dynamic> projectA,
    Map<String, dynamic> projectB,
  ) {
    final scoreA = _calculateScore(projectA);
    final scoreB = _calculateScore(projectB);

    final winner = scoreA > scoreB
        ? 'A'
        : scoreB > scoreA
        ? 'B'
        : 'tie';

    return ComparisonResult(
      scoreA: scoreA,
      scoreB: scoreB,
      winner: winner,
      scoreDiff: (scoreA - scoreB).abs(),
      factorsA: getDetailedFactors(projectA, colorA),
      factorsB: getDetailedFactors(projectB, colorB),
      differences: calculateDifferences(projectA, projectB),
      tableRows: prepareInfoTable(projectA, projectB),
    );
  }

  // ─── 1. حساب الدرجة ────────────────────────────────────────────────────────
  /// يستخدم السكور المحفوظ في Firestore أولاً لضمان التطابق مع بقية الشاشات.
  /// TODO: عند ربط الـ AI استبدل هذه الدالة بالدرجة القادمة من الموديل
  double _calculateScore(Map<String, dynamic> p) {
    // ─ استخدم السكور المحفوظ إذا كان موجوداً وغير صفري ─
    final rawScore = p['score'];
    if (rawScore != null && (rawScore as num).toDouble() > 0) {
      return (rawScore).toDouble();
    }

    // ─ fallback: احسب يدوياً إذا لم يكن السكور محفوظاً ─
    double score = 60.0;

    final budget = p['budget'] as String? ?? '';
    if (budget == 'High' || budget.contains('أكثر')) {
      score += 12;
    } else if (budget == 'Medium' || budget.contains('500'))
      score += 8;
    else if (budget == 'Low' || budget.contains('200'))
      score += 5;

    final area = p['area'] as String? ?? '';
    if (area == 'Large' || area.contains('كبير') || area.contains('200')) {
      score += 8;
    } else if (area == 'Medium' || area.contains('100'))
      score += 5;

    if (p['is24Hours'] == true) score += 3;
    if (p['hasInternalSeating'] == true) score += 3;
    if (p['hasCarService'] == true) score += 3;
    if (p['hasExternalTables'] == true) score += 2;
    if (p['hasParking'] == true) score += 2;

    final delivery = _parseDelivery(p['dependsOnDelivery']);
    if (delivery == 'High') {
      score += 3;
    } else if (delivery == 'Medium')
      score += 2;

    final age = p['shop_age'] as int?;
    if (age != null) {
      if (age >= 5) {
        score += 3;
      } else if (age >= 2)
        score += 1;
    }

    return score.clamp(0.0, 100.0);
  }

  // ─── 2. عوامل التقييم التفصيلية ────────────────────────────────────────────
  List<ComparisonFactor> getDetailedFactors(
    Map<String, dynamic> p,
    Color color,
  ) {
    final budget = p['budget'] as String? ?? '';
    final area = p['area'] as String? ?? '';
    final delivery = _parseDelivery(p['dependsOnDelivery']);

    // درجة الميزانية
    double budgetScore = 55;
    if (budget == 'High' || budget.contains('أكثر')) {
      budgetScore = 90;
    } else if (budget == 'Medium' || budget.contains('500'))
      budgetScore = 72;
    else if (budget == 'Low' || budget.contains('200'))
      budgetScore = 58;

    // درجة المساحة
    double areaScore = 55;
    if (area == 'Large' || area.contains('كبير') || area.contains('200')) {
      areaScore = 85;
    } else if (area == 'Medium' || area.contains('100'))
      areaScore = 68;

    // درجة الخدمات
    int services = 0;
    if (p['is24Hours'] == true) services++;
    if (p['hasInternalSeating'] == true) services++;
    if (p['hasCarService'] == true) services++;
    if (p['hasExternalTables'] == true) services++;
    if (p['hasParking'] == true) services++;
    if (delivery != 'Low') services++;
    double serviceScore = (50 + services * 8).clamp(0, 100).toDouble();

    // درجة الجمهور المستهدف
    const audienceScores = {
      'Mixed': 80.0,
      'Families': 78.0,
      'Employees': 72.0,
      'Youth': 68.0,
      'Students': 65.0,
    };
    final audience = p['targetAudience'] as String? ?? '';
    double audienceScore = audienceScores[audience] ?? 65.0;

    // درجة الموقع بناءً على المعالم القريبة
    const landmarkScores = {
      'Mall': 85.0,
      'Main Road': 80.0,
      'Hospital': 75.0,
      'School': 72.0,
      'Mosque': 68.0,
      'Inside Neighborhood': 60.0,
    };
    final landmark = p['nearbyLandmarks'] as String? ?? '';
    double locationScore = landmarkScores[landmark] ?? 62.0;

    // درجة أوقات العمل
    const hoursScores = {'Both': 85.0, 'Morning': 65.0, 'Evening': 70.0};
    final hours = p['opening_hours'] as String? ?? '';
    double hoursScore = hoursScores[hours] ?? 65.0;

    return [
      ComparisonFactor(
        label: 'الميزانية',
        icon: Icons.attach_money,
        score: budgetScore,
        color: color,
      ),
      ComparisonFactor(
        label: 'المساحة',
        icon: Icons.square_foot,
        score: areaScore,
        color: color,
      ),
      ComparisonFactor(
        label: 'الخدمات',
        icon: Icons.room_service_outlined,
        score: serviceScore,
        color: color,
      ),
      ComparisonFactor(
        label: 'الجمهور',
        icon: Icons.people_outline,
        score: audienceScore,
        color: color,
      ),
      ComparisonFactor(
        label: 'الموقع',
        icon: Icons.location_on_outlined,
        score: locationScore,
        color: color,
      ),
      ComparisonFactor(
        label: 'أوقات العمل',
        icon: Icons.access_time_outlined,
        score: hoursScore,
        color: color,
      ),
    ];
  }

  // ─── 3. حساب الفروقات ────────────────────────────────────────────────────
  List<ComparisonDiff> calculateDifferences(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final diffs = <ComparisonDiff>[];

    // الميزانية
    final budgetOrder = {'Low': 0, 'Medium': 1, 'High': 2};
    final bA = a['budget'] as String? ?? '';
    final bB = b['budget'] as String? ?? '';
    diffs.add(
      ComparisonDiff(
        label: 'الميزانية',
        icon: Icons.attach_money,
        valueA: _budgetLabel(bA),
        valueB: _budgetLabel(bB),
        aIsBetter: _compare(budgetOrder[bA], budgetOrder[bB]),
      ),
    );

    // المساحة
    final areaOrder = {'Small': 0, 'Medium': 1, 'Large': 2};
    final aA = a['area'] as String? ?? '';
    final aB = b['area'] as String? ?? '';
    diffs.add(
      ComparisonDiff(
        label: 'المساحة',
        icon: Icons.square_foot,
        valueA: _areaLabel(aA),
        valueB: _areaLabel(aB),
        aIsBetter: _compare(areaOrder[aA], areaOrder[aB]),
      ),
    );

    // الفئة المستهدفة
    final tA = a['targetAudience'] as String? ?? '—';
    final tB = b['targetAudience'] as String? ?? '—';
    diffs.add(
      ComparisonDiff(
        label: 'الفئة المستهدفة',
        icon: Icons.people_outline,
        valueA: _audienceLabel(tA),
        valueB: _audienceLabel(tB),
        aIsBetter: null, // لا يوجد أفضل وأسوأ — فقط مختلف
      ),
    );

    // التوصيل
    final deliveryOrder = {'Low': 0, 'Medium': 1, 'High': 2};
    final dA = _parseDelivery(a['dependsOnDelivery']);
    final dB = _parseDelivery(b['dependsOnDelivery']);
    diffs.add(
      ComparisonDiff(
        label: 'الاعتماد على التوصيل',
        icon: Icons.delivery_dining_outlined,
        valueA: _deliveryLabel(dA),
        valueB: _deliveryLabel(dB),
        aIsBetter: _compare(deliveryOrder[dA], deliveryOrder[dB]),
      ),
    );

    // أوقات العمل
    final hoursOrder = {'Morning': 0, 'Evening': 1, 'Both': 2};
    final hA = a['opening_hours'] as String? ?? '';
    final hB = b['opening_hours'] as String? ?? '';
    diffs.add(
      ComparisonDiff(
        label: 'أوقات العمل',
        icon: Icons.access_time_outlined,
        valueA: _hoursLabel(hA),
        valueB: _hoursLabel(hB),
        aIsBetter: _compare(hoursOrder[hA], hoursOrder[hB]),
      ),
    );

    // عمر المشروع (لو موجود في الاثنين)
    final ageA = a['shop_age'] as int?;
    final ageB = b['shop_age'] as int?;
    if (ageA != null || ageB != null) {
      diffs.add(
        ComparisonDiff(
          label: 'عمر المشروع',
          icon: Icons.history_outlined,
          valueA: ageA != null ? '$ageA سنة' : 'غير محدد',
          valueB: ageB != null ? '$ageB سنة' : 'غير محدد',
          aIsBetter: (ageA != null && ageB != null)
              ? _compare(ageA, ageB)
              : null,
        ),
      );
    }

    return diffs;
  }

  // ─── 4. إعداد بيانات الجدول الأساسي ──────────────────────────────────────
  List<ComparisonTableRow> prepareInfoTable(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    return [
      ComparisonTableRow(
        label: 'نوع النشاط',
        icon: Icons.store_outlined,
        valueA: a['businessType'] as String? ?? '—',
        valueB: b['businessType'] as String? ?? '—',
      ),
      ComparisonTableRow(
        label: 'الميزانية',
        icon: Icons.attach_money,
        valueA: _budgetLabel(a['budget'] as String? ?? ''),
        valueB: _budgetLabel(b['budget'] as String? ?? ''),
      ),
      ComparisonTableRow(
        label: 'المساحة',
        icon: Icons.square_foot,
        valueA: _areaLabel(a['area'] as String? ?? ''),
        valueB: _areaLabel(b['area'] as String? ?? ''),
      ),
      ComparisonTableRow(
        label: 'الفئة المستهدفة',
        icon: Icons.people_outline,
        valueA: _audienceLabel(a['targetAudience'] as String? ?? ''),
        valueB: _audienceLabel(b['targetAudience'] as String? ?? ''),
      ),
      ComparisonTableRow(
        label: 'المعالم القريبة',
        icon: Icons.location_on_outlined,
        valueA: _landmarkLabel(a['nearbyLandmarks'] as String? ?? ''),
        valueB: _landmarkLabel(b['nearbyLandmarks'] as String? ?? ''),
      ),
      ComparisonTableRow(
        label: 'أوقات العمل',
        icon: Icons.access_time_outlined,
        valueA: _hoursLabel(a['opening_hours'] as String? ?? ''),
        valueB: _hoursLabel(b['opening_hours'] as String? ?? ''),
      ),
      ComparisonTableRow(
        label: 'الاعتماد على التوصيل',
        icon: Icons.delivery_dining_outlined,
        valueA: _deliveryLabel(_parseDelivery(a['dependsOnDelivery'])),
        valueB: _deliveryLabel(_parseDelivery(b['dependsOnDelivery'])),
      ),
    ];
  }

  // ─── مساعد: يحوّل dependsOnDelivery من bool قديم أو String جديد ────────────
  static String _parseDelivery(dynamic v) {
    if (v is String) return v;
    if (v is bool) return v ? 'High' : 'Low';
    return 'Low';
  }

  // ─── مساعدات الترجمة (إنجليزي → عربي للعرض) ──────────────────────────────

  String _budgetLabel(String v) =>
      const {'Low': 'منخفضة', 'Medium': 'متوسطة', 'High': 'مرتفعة'}[v] ??
      (v.isEmpty ? '—' : v);

  String _areaLabel(String v) =>
      const {'Small': 'صغير', 'Medium': 'متوسط', 'Large': 'كبير'}[v] ??
      (v.isEmpty ? '—' : v);

  String _audienceLabel(String v) =>
      const {
        'Employees': 'موظفون',
        'Students': 'طلاب',
        'Mixed': 'متنوع',
        'Families': 'عائلات',
        'Youth': 'شباب',
      }[v] ??
      (v.isEmpty ? '—' : v);

  String _deliveryLabel(String v) =>
      const {'Low': 'منخفض', 'Medium': 'متوسط', 'High': 'مرتفع'}[v] ??
      (v.isEmpty ? '—' : v);

  String _hoursLabel(String v) =>
      const {
        'Morning': 'صباحي',
        'Evening': 'مسائي',
        'Both': 'صباحي ومسائي',
      }[v] ??
      (v.isEmpty ? '—' : v);

  String _landmarkLabel(String v) =>
      const {
        'School': 'مدرسة / جامعة',
        'Mall': 'مركز تجاري',
        'Hospital': 'مستشفى',
        'Mosque': 'مسجد',
        'Main Road': 'شارع رئيسي',
        'Inside Neighborhood': 'داخل حي سكني',
      }[v] ??
      (v.isEmpty ? '—' : v);

  // مقارنة رقمية — null يعني غير محدد
  bool? _compare(int? x, int? y) {
    if (x == null || y == null) return null;
    if (x > y) return true;
    if (x < y) return false;
    return null; // متساوي
  }
}
