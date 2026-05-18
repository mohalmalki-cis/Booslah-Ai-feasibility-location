import 'package:flutter/material.dart';

/// نموذج نوع النشاط التجاري — الأسبوع الحادي عشر
/// يمثّل نوعاً واحداً من أنواع الأنشطة التجارية المدعومة

class BusinessTypeModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final bool available;

  const BusinessTypeModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    this.available = false,
  });

  // ─── Mock Data: جميع أنواع الأنشطة ──────────────────────────────────────
  static const List<BusinessTypeModel> all = [
    BusinessTypeModel(
      id: 'cafe',
      name: 'مقهى',
      emoji: '☕',
      description: 'مقاهي ومحامص القهوة',
      color: Color(0xFF8B4513),
      available: true,
    ),
    BusinessTypeModel(
      id: 'restaurant',
      name: 'مطعم',
      emoji: '🍔',
      description: 'مطاعم ووجبات سريعة',
      color: Color(0xFFE53935),
      available: true,
    ),
    BusinessTypeModel(
      id: 'grocery',
      name: 'بقالة',
      emoji: '🛒',
      description: 'بقالات ومتاجر صغيرة',
      color: Color(0xFF43A047),
      available: true,
    ),
    BusinessTypeModel(
      id: 'bakery',
      name: 'مخبز',
      emoji: '🥖',
      description: 'مخابز وحلويات',
      color: Color(0xFFF57C00),
      available: false,
    ),
    BusinessTypeModel(
      id: 'pharmacy',
      name: 'صيدلية',
      emoji: '💊',
      description: 'صيدليات ومستلزمات طبية',
      color: Color(0xFF1E88E5),
      available: false,
    ),
    BusinessTypeModel(
      id: 'salon',
      name: 'صالون',
      emoji: '💇',
      description: 'صالونات حلاقة وتجميل',
      color: Color(0xFFD81B60),
      available: false,
    ),
    BusinessTypeModel(
      id: 'gym',
      name: 'نادي رياضي',
      emoji: '💪',
      description: 'أندية رياضية ولياقة',
      color: Color(0xFF00897B),
      available: false,
    ),
    BusinessTypeModel(
      id: 'bookstore',
      name: 'مكتبة',
      emoji: '📚',
      description: 'مكتبات وقرطاسية',
      color: Color(0xFF5E35B1),
      available: false,
    ),
    BusinessTypeModel(
      id: 'clothing',
      name: 'ملابس',
      emoji: '👔',
      description: 'متاجر ملابس وأزياء',
      color: Color(0xFF6D4C41),
      available: false,
    ),
  ];

  // ─── الأنواع المتاحة فقط ─────────────────────────────────────────────────
  static List<BusinessTypeModel> get availableTypes =>
      all.where((t) => t.available).toList();

  // ─── جلب نوع بالـ ID ─────────────────────────────────────────────────────
  static BusinessTypeModel? getById(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── تحويل إلى Map (للحفظ في Firestore) ──────────────────────────────────
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'description': description,
        'available': available,
      };
}
