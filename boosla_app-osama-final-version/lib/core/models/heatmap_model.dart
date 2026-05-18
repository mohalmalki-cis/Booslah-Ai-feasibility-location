import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// نقطة حرارية واحدة على الخريطة
class HeatPoint {
  final LatLng position;
  final double intensity; // 0.0 – 1.0
  final String? label;   // اسم الحي (اختياري)

  const HeatPoint({
    required this.position,
    required this.intensity,
    this.label,
  });
}

/// فئة نشاط تجاري مع نقاطها الحرارية
class HeatmapCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final List<HeatPoint> points;

  const HeatmapCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.points,
  });

  /// متوسط الكثافة للفئة
  double get averageIntensity {
    if (points.isEmpty) return 0;
    return points.map((p) => p.intensity).reduce((a, b) => a + b) / points.length;
  }

  /// أعلى نقطة كثافة
  HeatPoint? get hotspot =>
      points.isEmpty ? null : points.reduce((a, b) => a.intensity > b.intensity ? a : b);
}
