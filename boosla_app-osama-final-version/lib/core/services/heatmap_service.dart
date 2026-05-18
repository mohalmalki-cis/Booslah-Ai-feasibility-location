import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/heatmap_model.dart';

/// خدمة الخريطة الحرارية — الأسبوع الثالث عشر
///
/// المسؤوليات:
/// - تخزين بيانات الـ Heatmap لكل فئة نشاط تجاري
/// - تحويل النقاط إلى CircleMarker لـ flutter_map
/// - دعم تصفية الفئات واسترجاع الإحصائيات
class HeatmapService {
  HeatmapService._();
  static final HeatmapService instance = HeatmapService._();

  // ─── Mock Data: 4 أنواع نشاط تجاري ─────────────────────────────────────────
  static final List<HeatmapCategory> categories = [
    // ──────────────────────────────────────────────────────────────── ☕ المقاهي
    HeatmapCategory(
      id: 'cafe',
      label: 'مشاريع المقاهي',
      emoji: '☕',
      color: const Color(0xFF795548),
      points: [
        // وسط الرياض
        HeatPoint(position: const LatLng(24.6877, 46.7219), intensity: 0.95, label: 'العليا'),
        HeatPoint(position: const LatLng(24.7136, 46.6753), intensity: 0.85, label: 'البطحاء'),
        // شمال الرياض
        HeatPoint(position: const LatLng(24.8200, 46.6350), intensity: 0.80, label: 'النرجس'),
        HeatPoint(position: const LatLng(24.8500, 46.7100), intensity: 0.70, label: 'الياسمين'),
        HeatPoint(position: const LatLng(24.8750, 46.6600), intensity: 0.60, label: 'الصحافة'),
        HeatPoint(position: const LatLng(24.8050, 46.7500), intensity: 0.55, label: 'الروضة'),
        // جنوب الرياض
        HeatPoint(position: const LatLng(24.5900, 46.7100), intensity: 0.75, label: 'شبرا'),
        HeatPoint(position: const LatLng(24.5600, 46.6800), intensity: 0.50, label: 'عرقة'),
        HeatPoint(position: const LatLng(24.6200, 46.7400), intensity: 0.65, label: 'الشفا'),
        // شرق الرياض
        HeatPoint(position: const LatLng(24.7400, 46.8200), intensity: 0.70, label: 'المونسية'),
        HeatPoint(position: const LatLng(24.7100, 46.8600), intensity: 0.45, label: 'قرطبة'),
        HeatPoint(position: const LatLng(24.6600, 46.8000), intensity: 0.60, label: 'الحمراء'),
        // غرب الرياض
        HeatPoint(position: const LatLng(24.7000, 46.5800), intensity: 0.55, label: 'الرحمانية'),
        HeatPoint(position: const LatLng(24.7300, 46.5400), intensity: 0.40, label: 'الشهداء'),
        HeatPoint(position: const LatLng(24.6500, 46.6000), intensity: 0.65, label: 'لبن'),
      ],
    ),

    // ────────────────────────────────────────────────────────────── 🍔 المطاعم
    HeatmapCategory(
      id: 'restaurant',
      label: 'مشاريع المطاعم',
      emoji: '🍔',
      color: const Color(0xFFE53935),
      points: [
        // وسط الرياض
        HeatPoint(position: const LatLng(24.6877, 46.7219), intensity: 0.95, label: 'العليا'),
        HeatPoint(position: const LatLng(24.7050, 46.6900), intensity: 0.90, label: 'البطحاء'),
        // شمال الرياض
        HeatPoint(position: const LatLng(24.8300, 46.6200), intensity: 0.85, label: 'النرجس'),
        HeatPoint(position: const LatLng(24.8600, 46.6900), intensity: 0.75, label: 'الياسمين'),
        HeatPoint(position: const LatLng(24.9000, 46.6500), intensity: 0.55, label: 'الصحافة الشمالية'),
        HeatPoint(position: const LatLng(24.8100, 46.7600), intensity: 0.65, label: 'الروضة'),
        HeatPoint(position: const LatLng(24.8450, 46.7300), intensity: 0.70, label: 'العارض'),
        // جنوب الرياض
        HeatPoint(position: const LatLng(24.5800, 46.7000), intensity: 0.80, label: 'شبرا'),
        HeatPoint(position: const LatLng(24.5500, 46.6600), intensity: 0.60, label: 'عرقة'),
        HeatPoint(position: const LatLng(24.6100, 46.6500), intensity: 0.70, label: 'المصانع'),
        HeatPoint(position: const LatLng(24.6300, 46.7500), intensity: 0.55, label: 'الشفا'),
        // شرق الرياض
        HeatPoint(position: const LatLng(24.7500, 46.8300), intensity: 0.75, label: 'المونسية'),
        HeatPoint(position: const LatLng(24.7000, 46.8700), intensity: 0.50, label: 'قرطبة'),
        // غرب الرياض
        HeatPoint(position: const LatLng(24.6900, 46.5700), intensity: 0.60, label: 'الرحمانية'),
        HeatPoint(position: const LatLng(24.7200, 46.5300), intensity: 0.45, label: 'الشهداء'),
      ],
    ),

    // ────────────────────────────────────────────────────────────── 🛒 التجزئة
    HeatmapCategory(
      id: 'retail',
      label: 'مشاريع التجزئة',
      emoji: '🛒',
      color: const Color(0xFF5B6AF0),
      points: [
        // وسط الرياض
        HeatPoint(position: const LatLng(24.6877, 46.7219), intensity: 0.90, label: 'العليا'),
        HeatPoint(position: const LatLng(24.7200, 46.6750), intensity: 0.80, label: 'البطحاء'),
        // شمال الرياض
        HeatPoint(position: const LatLng(24.8150, 46.6400), intensity: 0.75, label: 'النرجس'),
        HeatPoint(position: const LatLng(24.8550, 46.7000), intensity: 0.85, label: 'الياسمين'),
        HeatPoint(position: const LatLng(24.8900, 46.6700), intensity: 0.60, label: 'الصحافة'),
        HeatPoint(position: const LatLng(24.7950, 46.7400), intensity: 0.65, label: 'الروضة'),
        // جنوب الرياض
        HeatPoint(position: const LatLng(24.5950, 46.7200), intensity: 0.70, label: 'شبرا'),
        HeatPoint(position: const LatLng(24.5650, 46.6900), intensity: 0.55, label: 'عرقة'),
        HeatPoint(position: const LatLng(24.6050, 46.6600), intensity: 0.80, label: 'المصانع'),
        HeatPoint(position: const LatLng(24.6350, 46.7600), intensity: 0.50, label: 'الشفا'),
        // شرق الرياض
        HeatPoint(position: const LatLng(24.7350, 46.8100), intensity: 0.95, label: 'المونسية'),
        HeatPoint(position: const LatLng(24.7150, 46.8500), intensity: 0.70, label: 'قرطبة'),
        HeatPoint(position: const LatLng(24.6700, 46.8200), intensity: 0.60, label: 'الحمراء'),
        // غرب الرياض
        HeatPoint(position: const LatLng(24.7050, 46.5900), intensity: 0.65, label: 'الرحمانية'),
        HeatPoint(position: const LatLng(24.6400, 46.6100), intensity: 0.75, label: 'لبن'),
      ],
    ),

  ];

  // ─── جلب فئة بالـ ID ─────────────────────────────────────────────────────
  HeatmapCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── بناء دوائر الـ Heatmap ──────────────────────────────────────────────
  /// يُحوّل نقاط الفئة إلى قائمة CircleMarker جاهزة لـ flutter_map
  List<CircleMarker> buildCircles(HeatmapCategory category) {
    final List<CircleMarker> circles = [];

    for (final pt in category.points) {
      final base = category.color;
      final inv  = pt.intensity;

      // حجم الدائرة يتغير حسب الـ intensity (800م → 2000م)
      final maxR = 800.0 + (inv * 1200.0);

      // طبقات من الخارج للداخل: فاتح ← غامق
      final layers = [
        (r: maxR,          op: 0.03 * inv),
        (r: maxR * 0.78,   op: 0.07 * inv),
        (r: maxR * 0.58,   op: 0.12 * inv),
        (r: maxR * 0.40,   op: 0.20 * inv),
        (r: maxR * 0.24,   op: 0.32 * inv),
        (r: maxR * 0.12,   op: 0.50 * inv),
      ];

      for (final layer in layers) {
        circles.add(CircleMarker(
          point: pt.position,
          radius: layer.r,
          useRadiusInMeter: true,
          color: base.withOpacity(layer.op.clamp(0.0, 1.0)),
          borderStrokeWidth: 0,
          borderColor: Colors.transparent,
        ));
      }
    }

    return circles;
  }

  // ─── إحصائيات الفئة ──────────────────────────────────────────────────────
  /// أعلى 3 مناطق كثافة في فئة معينة
  List<HeatPoint> getTopHotspots(String categoryId, {int count = 3}) {
    final cat = getCategoryById(categoryId);
    if (cat == null) return [];
    final sorted = List<HeatPoint>.from(cat.points)
      ..sort((a, b) => b.intensity.compareTo(a.intensity));
    return sorted.take(count).toList();
  }
}
