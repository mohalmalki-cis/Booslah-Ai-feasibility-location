// ─── اختبارات الوحدة الشاملة — الأسبوع الرابع عشر ───────────────────────────
// تغطّي: ProjectModel._parseDelivery، ProjectService._calculateScore،
//         ComparisonService، SettingsService
//
// تشغيل: flutter test test/unit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:boosla_app/core/models/project_model.dart';
import 'package:boosla_app/core/models/comparison_result.dart';
import 'package:boosla_app/core/services/comparison_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// مساعد: ينشئ Map مشروع بقيم افتراضية قابلة للتخصيص
// ─────────────────────────────────────────────────────────────────────────────
Map<String, dynamic> _makeProject({
  String businessType = 'مقهى',
  String businessEmoji = '☕',
  String budget = 'Medium',
  String area = 'Medium',
  bool is24Hours = false,
  bool hasInternalSeating = false,
  bool hasCarService = false,
  bool hasExternalTables = false,
  bool hasParking = false,
  dynamic dependsOnDelivery = 'Low',
  String targetAudience = 'Mixed',
  String nearbyLandmarks = 'Main Road',
  String openingHours = 'Both',
  int? shopAge,
  double? score,
}) {
  return {
    'id': 'test_id',
    'businessId': 'b1',
    'businessType': businessType,
    'businessEmoji': businessEmoji,
    'projectName': 'مشروع تجريبي',
    'budget': budget,
    'area': area,
    'is24Hours': is24Hours,
    'hasInternalSeating': hasInternalSeating,
    'hasCarService': hasCarService,
    'hasExternalTables': hasExternalTables,
    'hasParking': hasParking,
    'dependsOnDelivery': dependsOnDelivery,
    'targetAudience': targetAudience,
    'nearbyLandmarks': nearbyLandmarks,
    'opening_hours': openingHours,
    'shop_age': ?shopAge,
    'score': ?score,
  };
}

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // 1. اختبارات ProjectModel._parseDelivery (عبر fromMap)
  // ───────────────────────────────────────────────────────────────────────────
  group('ProjectModel._parseDelivery', () {
    test('يقبل String "Low"', () {
      final m = ProjectModel.fromMap(
        _makeProject(dependsOnDelivery: 'Low')
          ..['createdAt'] = DateTime.now().toIso8601String(),
        'uid1',
      );
      expect(m.dependsOnDelivery, equals('Low'));
    });

    test('يقبل String "Medium"', () {
      final m = ProjectModel.fromMap(
        _makeProject(dependsOnDelivery: 'Medium')
          ..['createdAt'] = DateTime.now().toIso8601String(),
        'uid1',
      );
      expect(m.dependsOnDelivery, equals('Medium'));
    });

    test('يقبل String "High"', () {
      final m = ProjectModel.fromMap(
        _makeProject(dependsOnDelivery: 'High')
          ..['createdAt'] = DateTime.now().toIso8601String(),
        'uid1',
      );
      expect(m.dependsOnDelivery, equals('High'));
    });

    test('يحوّل bool true إلى "High" (backward compat)', () {
      final m = ProjectModel.fromMap(
        _makeProject(dependsOnDelivery: true)
          ..['createdAt'] = DateTime.now().toIso8601String(),
        'uid1',
      );
      expect(m.dependsOnDelivery, equals('High'));
    });

    test('يحوّل bool false إلى "Low" (backward compat)', () {
      final m = ProjectModel.fromMap(
        _makeProject(dependsOnDelivery: false)
          ..['createdAt'] = DateTime.now().toIso8601String(),
        'uid1',
      );
      expect(m.dependsOnDelivery, equals('Low'));
    });

    test('يعطي "Low" عند null', () {
      final data = _makeProject()
        ..['createdAt'] = DateTime.now().toIso8601String();
      data.remove('dependsOnDelivery');
      final m = ProjectModel.fromMap(data, 'uid1');
      expect(m.dependsOnDelivery, equals('Low'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 2. اختبارات ProjectModel.fromMap — الحقول الأساسية
  // ───────────────────────────────────────────────────────────────────────────
  group('ProjectModel.fromMap', () {
    test('يحوّل shop_age بشكل صحيح', () {
      final data = _makeProject(shopAge: 5)
        ..['createdAt'] = DateTime.now().toIso8601String();
      final m = ProjectModel.fromMap(data, 'uid1');
      expect(m.shopAge, equals(5));
    });

    test('shopAge يكون null إذا لم يُمرَّر', () {
      final data = _makeProject()
        ..['createdAt'] = DateTime.now().toIso8601String();
      final m = ProjectModel.fromMap(data, 'uid1');
      expect(m.shopAge, isNull);
    });

    test('يقرأ score بشكل صحيح', () {
      final data = _makeProject(score: 78.5)
        ..['createdAt'] = DateTime.now().toIso8601String();
      final m = ProjectModel.fromMap(data, 'uid1');
      expect(m.score, equals(78.5));
    });

    test('score يكون null إذا لم يُمرَّر', () {
      final data = _makeProject()
        ..['createdAt'] = DateTime.now().toIso8601String();
      final m = ProjectModel.fromMap(data, 'uid1');
      expect(m.score, isNull);
    });

    test('toMap → fromMap تعيد نفس البيانات', () {
      final data = _makeProject(
        budget: 'High',
        area: 'Large',
        dependsOnDelivery: 'High',
        shopAge: 3,
        score: 88.0,
      )..['createdAt'] = DateTime.now().toIso8601String();
      final original = ProjectModel.fromMap(data, 'uid1');
      final copy = ProjectModel.fromMap(original.toMap(), 'uid1');
      expect(copy.budget, equals(original.budget));
      expect(copy.area, equals(original.area));
      expect(copy.dependsOnDelivery, equals(original.dependsOnDelivery));
      expect(copy.shopAge, equals(original.shopAge));
      expect(copy.score, equals(original.score));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 3. اختبارات ComparisonService._parseDelivery
  // ───────────────────────────────────────────────────────────────────────────
  group('ComparisonService — _parseDelivery', () {
    final svc = ComparisonService.instance;

    test('مشروع بتوصيل bool true → High يُؤثّر على النتيجة', () {
      final a = _makeProject(dependsOnDelivery: true, score: null);
      final b = _makeProject(dependsOnDelivery: false, score: null);
      final result = svc.compare(a, b);
      // A يعتمد على التوصيل High، B لا → A أعلى
      expect(result.scoreA, greaterThan(result.scoreB));
    });

    test('_parseDelivery في calculateDifferences لا يرمي exception', () {
      final a = _makeProject(dependsOnDelivery: true);
      final b = _makeProject(dependsOnDelivery: 'Medium');
      expect(() => svc.calculateDifferences(a, b), returnsNormally);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 4. اختبارات ComparisonService.compare — حساب الدرجة
  // ───────────────────────────────────────────────────────────────────────────
  group('ComparisonService.compare — حساب الدرجة', () {
    final svc = ComparisonService.instance;

    test('يستخدم السكور المحفوظ إذا كان موجوداً', () {
      final a = _makeProject(score: 90.0);
      final b = _makeProject(score: 70.0);
      final result = svc.compare(a, b);
      expect(result.scoreA, equals(90.0));
      expect(result.scoreB, equals(70.0));
    });

    test('winner = A عندما scoreA > scoreB', () {
      final a = _makeProject(score: 80.0);
      final b = _makeProject(score: 60.0);
      final result = svc.compare(a, b);
      expect(result.winner, equals('A'));
    });

    test('winner = B عندما scoreB > scoreA', () {
      final a = _makeProject(score: 60.0);
      final b = _makeProject(score: 80.0);
      final result = svc.compare(a, b);
      expect(result.winner, equals('B'));
    });

    test('winner = tie عندما scoreA == scoreB', () {
      final a = _makeProject(score: 75.0);
      final b = _makeProject(score: 75.0);
      final result = svc.compare(a, b);
      expect(result.winner, equals('tie'));
    });

    test('scoreDiff صحيحة', () {
      final a = _makeProject(score: 85.0);
      final b = _makeProject(score: 70.0);
      final result = svc.compare(a, b);
      expect(result.scoreDiff, equals(15.0));
    });

    test('الدرجة الاحتياطية: ميزانية High أعلى من Low', () {
      final a = _makeProject(budget: 'High'); // بدون score محفوظ
      final b = _makeProject(budget: 'Low');
      final result = svc.compare(a, b);
      expect(result.scoreA, greaterThan(result.scoreB));
    });

    test('الدرجة الاحتياطية: مساحة Large أعلى من Small', () {
      final a = _makeProject(area: 'Large');
      final b = _makeProject(area: 'Small');
      final result = svc.compare(a, b);
      expect(result.scoreA, greaterThan(result.scoreB));
    });

    test('الدرجة الاحتياطية: shop_age >= 5 يضيف نقاط', () {
      final a = _makeProject(shopAge: 5);
      final b = _makeProject(); // بدون عمر
      final result = svc.compare(a, b);
      expect(result.scoreA, greaterThan(result.scoreB));
    });

    test('الدرجة الاحتياطية: لا تتجاوز 100', () {
      // أقصى ما يمكن: ميزانية High + مساحة Large + كل الخدائص + عمر 5+
      final a = _makeProject(
        budget: 'High',
        area: 'Large',
        is24Hours: true,
        hasInternalSeating: true,
        hasCarService: true,
        hasExternalTables: true,
        hasParking: true,
        dependsOnDelivery: 'High',
        shopAge: 10,
      );
      final b = _makeProject(score: 0.0);
      final result = svc.compare(a, b);
      expect(result.scoreA, lessThanOrEqualTo(100.0));
    });

    test('الدرجة الاحتياطية: لا تقل عن 0', () {
      final a = _makeProject(budget: 'Low', area: 'Small');
      final b = _makeProject(score: 0.0);
      final result = svc.compare(a, b);
      expect(result.scoreA, greaterThanOrEqualTo(0.0));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 5. اختبارات ComparisonService.getDetailedFactors
  // ───────────────────────────────────────────────────────────────────────────
  group('ComparisonService.getDetailedFactors', () {
    final svc = ComparisonService.instance;

    test('تُعيد 6 عوامل', () {
      final factors = svc.getDetailedFactors(
        _makeProject(),
        ComparisonService.colorA,
      );
      expect(factors.length, equals(6));
    });

    test('كل العوامل بين 0 و 100', () {
      final factors = svc.getDetailedFactors(
        _makeProject(
          budget: 'High',
          area: 'Large',
          targetAudience: 'Families',
          nearbyLandmarks: 'Mall',
          openingHours: 'Both',
        ),
        ComparisonService.colorB,
      );
      for (final f in factors) {
        expect(
          f.score,
          inInclusiveRange(0.0, 100.0),
          reason: 'عامل "${f.label}" خارج النطاق',
        );
      }
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 6. اختبارات ComparisonService.calculateDifferences
  // ───────────────────────────────────────────────────────────────────────────
  group('ComparisonService.calculateDifferences', () {
    final svc = ComparisonService.instance;

    test('تُعيد قائمة غير فارغة', () {
      final diffs = svc.calculateDifferences(_makeProject(), _makeProject());
      expect(diffs, isNotEmpty);
    });

    test('اختلاف الميزانية يُكتشف صحيحاً', () {
      final a = _makeProject(budget: 'High');
      final b = _makeProject(budget: 'Low');
      final diffs = svc.calculateDifferences(a, b);
      final budgetDiff = diffs.firstWhere((d) => d.label == 'الميزانية');
      expect(budgetDiff.aIsBetter, isTrue);
    });

    test('اختلاف المساحة يُكتشف صحيحاً', () {
      final a = _makeProject(area: 'Small');
      final b = _makeProject(area: 'Large');
      final diffs = svc.calculateDifferences(a, b);
      final areaDiff = diffs.firstWhere((d) => d.label == 'المساحة');
      expect(areaDiff.aIsBetter, isFalse);
    });

    test('الفئة المستهدفة aIsBetter = null (لا يوجد أفضل)', () {
      final diffs = svc.calculateDifferences(_makeProject(), _makeProject());
      final audienceDiff = diffs.firstWhere(
        (d) => d.label == 'الفئة المستهدفة',
      );
      expect(audienceDiff.aIsBetter, isNull);
    });

    test('عمر المشروع يظهر فقط إذا كان موجوداً في أحد المشروعين', () {
      // كلاهما بدون عمر — لا يجب أن يظهر
      final diffs = svc.calculateDifferences(_makeProject(), _makeProject());
      final hasAge = diffs.any((d) => d.label == 'عمر المشروع');
      expect(hasAge, isFalse);

      // أحدهما عنده عمر — يجب أن يظهر
      final diffsWithAge = svc.calculateDifferences(
        _makeProject(shopAge: 3),
        _makeProject(),
      );
      final hasAgeWithAge = diffsWithAge.any((d) => d.label == 'عمر المشروع');
      expect(hasAgeWithAge, isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 7. اختبارات ComparisonService.prepareInfoTable
  // ───────────────────────────────────────────────────────────────────────────
  group('ComparisonService.prepareInfoTable', () {
    final svc = ComparisonService.instance;

    test('تُعيد 7 صفوف', () {
      final rows = svc.prepareInfoTable(_makeProject(), _makeProject());
      expect(rows.length, equals(7));
    });

    test('ترجمة الميزانية صحيحة', () {
      final rows = svc.prepareInfoTable(
        _makeProject(budget: 'High'),
        _makeProject(budget: 'Low'),
      );
      final budgetRow = rows.firstWhere((r) => r.label == 'الميزانية');
      expect(budgetRow.valueA, equals('مرتفعة'));
      expect(budgetRow.valueB, equals('منخفضة'));
    });

    test('ترجمة المساحة صحيحة', () {
      final rows = svc.prepareInfoTable(
        _makeProject(area: 'Large'),
        _makeProject(area: 'Small'),
      );
      final areaRow = rows.firstWhere((r) => r.label == 'المساحة');
      expect(areaRow.valueA, equals('كبير'));
      expect(areaRow.valueB, equals('صغير'));
    });

    test('ترجمة التوصيل صحيحة مع bool قديم', () {
      final rows = svc.prepareInfoTable(
        _makeProject(dependsOnDelivery: true), // bool قديم
        _makeProject(dependsOnDelivery: 'Low'),
      );
      final row = rows.firstWhere((r) => r.label == 'الاعتماد على التوصيل');
      expect(row.valueA, equals('مرتفع'));
      expect(row.valueB, equals('منخفض'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 8. اختبارات ComparisonResult
  // ───────────────────────────────────────────────────────────────────────────
  group('ComparisonResult', () {
    test('يُنشأ بشكل صحيح', () {
      final result = ComparisonResult(
        scoreA: 80,
        scoreB: 70,
        winner: 'A',
        scoreDiff: 10,
        factorsA: [],
        factorsB: [],
        differences: [],
        tableRows: [],
      );
      expect(result.scoreA, equals(80));
      expect(result.winner, equals('A'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 9. اختبارات التوافق مع البيانات القديمة (backward compatibility)
  // ───────────────────────────────────────────────────────────────────────────
  group('Backward Compatibility', () {
    test('مشروع قديم بـ dependsOnDelivery=true لا يرمي استثناء', () {
      final old = {
        'id': 'old1',
        'businessId': 'b1',
        'businessType': 'مطعم',
        'businessEmoji': '🍽️',
        'projectName': 'مطعم قديم',
        'is24Hours': false,
        'hasInternalSeating': true,
        'hasCarService': false,
        'hasExternalTables': false,
        'dependsOnDelivery': true, // قيمة bool قديمة
        'targetAudience': 'Families',
        'area': 'Medium',
        'budget': 'Medium',
        'nearbyLandmarks': 'Mall',
        'createdAt': DateTime.now().toIso8601String(),
      };
      expect(() => ProjectModel.fromMap(old, 'uid1'), returnsNormally);
    });

    test('مشروع قديم بـ dependsOnDelivery=false لا يرمي استثناء', () {
      final old = {
        'id': 'old2',
        'businessId': 'b2',
        'businessType': 'بقالة',
        'businessEmoji': '🛒',
        'projectName': 'بقالة قديمة',
        'is24Hours': true,
        'hasInternalSeating': false,
        'hasCarService': false,
        'hasExternalTables': false,
        'dependsOnDelivery': false, // قيمة bool قديمة
        'targetAudience': 'Mixed',
        'area': 'Small',
        'budget': 'Low',
        'nearbyLandmarks': 'Mosque',
        'createdAt': DateTime.now().toIso8601String(),
      };
      expect(() => ProjectModel.fromMap(old, 'uid1'), returnsNormally);
    });

    test('مشروع قديم يُقارَن بشكل صحيح في ComparisonService', () {
      final oldProject = {
        'id': 'old3',
        'dependsOnDelivery': true, // bool قديم
        'budget': 'Medium',
        'area': 'Large',
        'is24Hours': false,
        'hasInternalSeating': false,
        'hasCarService': false,
        'hasExternalTables': false,
        'hasParking': false,
        'targetAudience': 'Youth',
        'nearbyLandmarks': 'School',
        'opening_hours': 'Evening',
      };
      final newProject = _makeProject(dependsOnDelivery: 'High');
      expect(
        () => ComparisonService.instance.compare(oldProject, newProject),
        returnsNormally,
      );
    });
  });
}
