import 'package:flutter/material.dart';

/// نموذج نتيجة المقارنة بين مشروعين
/// يُنتج من ComparisonService.compare()

// ─── عامل تقييم واحد (ميزانية / مساحة / خدمات ...) ─────────────────────────
class ComparisonFactor {
  final String label;
  final IconData icon;
  final double score;   // 0 - 100
  final Color color;

  const ComparisonFactor({
    required this.label,
    required this.icon,
    required this.score,
    required this.color,
  });
}

// ─── فرق واحد بين مشروعين في حقل معين ───────────────────────────────────────
class ComparisonDiff {
  final String label;
  final IconData icon;
  final String valueA;
  final String valueB;
  final bool? aIsBetter; // true=A أفضل، false=B أفضل، null=متساويان

  const ComparisonDiff({
    required this.label,
    required this.icon,
    required this.valueA,
    required this.valueB,
    this.aIsBetter,
  });
}

// ─── صف في جدول المعلومات الأساسية ──────────────────────────────────────────
class ComparisonTableRow {
  final String label;
  final IconData icon;
  final String valueA;
  final String valueB;

  const ComparisonTableRow({
    required this.label,
    required this.icon,
    required this.valueA,
    required this.valueB,
  });
}

// ─── نتيجة المقارنة الكاملة ───────────────────────────────────────────────
class ComparisonResult {
  final double scoreA;
  final double scoreB;
  final String winner;              // 'A' | 'B' | 'tie'
  final double scoreDiff;           // الفرق بين الدرجتين
  final List<ComparisonFactor> factorsA;
  final List<ComparisonFactor> factorsB;
  final List<ComparisonDiff> differences;
  final List<ComparisonTableRow> tableRows;

  const ComparisonResult({
    required this.scoreA,
    required this.scoreB,
    required this.winner,
    required this.scoreDiff,
    required this.factorsA,
    required this.factorsB,
    required this.differences,
    required this.tableRows,
  });
}
