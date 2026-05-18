import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المشروع — الأسبوع العاشر
/// يمثّل مشروعاً واحداً مخزّناً في Firestore تحت:
///   users/{uid}/projects/{projectId}

class ProjectModel {
  final String id;
  final String uid; // معرّف المالك
  final String businessId;
  final String businessType;
  final String businessEmoji;
  final String projectName;

  // ─── الخصائص المشتركة ────────────────────────────────────────────────────
  final bool is24Hours;
  final bool hasInternalSeating;
  final bool hasCarService;
  final bool hasExternalTables;
  final String dependsOnDelivery; // Low / Medium / High

  // ─── الحقول المشتركة ─────────────────────────────────────────────────────
  final String targetAudience;
  final String area;
  final String budget;
  final String nearbyLandmarks;

  // ─── الحقول الخاصة بكل نوع ───────────────────────────────────────────────
  final String? cafeType;
  final String? restaurantType;
  final bool? hasParking;
  final String? openingHours; // Morning / Evening / Both
  final int? shopAge;         // عمر المشروع بالسنوات (اختياري)

  // ─── بيانات التحليل ──────────────────────────────────────────────────────
  final double? score;
  final DateTime createdAt;

  // ─── نتائج الذكاء الاصطناعي ──────────────────────────────────────────────
  final String? aiBestNeighborhood;
  final List<Map<String, dynamic>>? aiTopNeighborhoods;
  final double? aiLatitude;
  final double? aiLongitude;
  final String? aiPredictedZone;

  const ProjectModel({
    required this.id,
    required this.uid,
    required this.businessId,
    required this.businessType,
    required this.businessEmoji,
    required this.projectName,
    required this.is24Hours,
    required this.hasInternalSeating,
    required this.hasCarService,
    required this.hasExternalTables,
    required this.dependsOnDelivery,
    required this.targetAudience,
    required this.area,
    required this.budget,
    required this.nearbyLandmarks,
    required this.createdAt,
    this.cafeType,
    this.restaurantType,
    this.hasParking,
    this.openingHours,
    this.shopAge,
    this.score,
    this.aiBestNeighborhood,
    this.aiTopNeighborhoods,
    this.aiLatitude,
    this.aiLongitude,
    this.aiPredictedZone,
  });

  // ─── مساعد: يفكّ ai_top_neighborhoods من Firestore أو من Map قديم ──────
  static List<Map<String, dynamic>>? _parseTopNeighborhoods(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return null;
  }

  // ─── مساعد: يحوّل dependsOnDelivery من bool قديم أو String جديد ────────────
  static String _parseDelivery(dynamic v) {
    if (v is String) return v;
    if (v is bool)   return v ? 'High' : 'Low';
    return 'Low';
  }

  // ─── من Firestore ─────────────────────────────────────────────────────────
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      businessId: data['businessId'] as String? ?? '',
      businessType: data['businessType'] as String? ?? '',
      businessEmoji: data['businessEmoji'] as String? ?? '🏪',
      projectName: data['projectName'] as String? ?? '',
      is24Hours: data['is24Hours'] as bool? ?? false,
      hasInternalSeating: data['hasInternalSeating'] as bool? ?? false,
      hasCarService: data['hasCarService'] as bool? ?? false,
      hasExternalTables: data['hasExternalTables'] as bool? ?? false,
      dependsOnDelivery: _parseDelivery(data['dependsOnDelivery']),
      targetAudience: data['targetAudience'] as String? ?? '',
      area: data['area'] as String? ?? '',
      budget: data['budget'] as String? ?? '',
      nearbyLandmarks: data['nearbyLandmarks'] as String? ?? '',
      cafeType: data['cafeType'] as String?,
      restaurantType: data['restaurantType'] as String?,
      hasParking: data['hasParking'] as bool?,
      openingHours: data['opening_hours'] as String?,
      shopAge: data['shop_age'] as int?,
      score: (data['score'] as num?)?.toDouble(),
      aiBestNeighborhood: data['ai_best_neighborhood'] as String?,
      aiTopNeighborhoods: _parseTopNeighborhoods(data['ai_top_neighborhoods']),
      aiLatitude: (data['ai_latitude'] as num?)?.toDouble(),
      aiLongitude: (data['ai_longitude'] as num?)?.toDouble(),
      aiPredictedZone: data['ai_predicted_zone'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  // ─── إلى Firestore ────────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'businessId': businessId,
      'businessType': businessType,
      'businessEmoji': businessEmoji,
      'projectName': projectName,
      'is24Hours': is24Hours,
      'hasInternalSeating': hasInternalSeating,
      'hasCarService': hasCarService,
      'hasExternalTables': hasExternalTables,
      'dependsOnDelivery': dependsOnDelivery,
      'targetAudience': targetAudience,
      'area': area,
      'budget': budget,
      'nearbyLandmarks': nearbyLandmarks,
      if (cafeType != null) 'cafeType': cafeType,
      if (restaurantType != null) 'restaurantType': restaurantType,
      if (hasParking != null) 'hasParking': hasParking,
      if (openingHours != null) 'opening_hours': openingHours,
      if (shopAge != null) 'shop_age': shopAge,
      if (score != null) 'score': score,
      if (aiBestNeighborhood != null) 'ai_best_neighborhood': aiBestNeighborhood,
      if (aiTopNeighborhoods != null) 'ai_top_neighborhoods': aiTopNeighborhoods,
      if (aiLatitude != null) 'ai_latitude': aiLatitude,
      if (aiLongitude != null) 'ai_longitude': aiLongitude,
      if (aiPredictedZone != null) 'ai_predicted_zone': aiPredictedZone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ─── من LocalStorage (Map القديم) ────────────────────────────────────────
  factory ProjectModel.fromMap(Map<String, dynamic> map, String uid) {
    return ProjectModel(
      id: map['id'] as String? ?? '',
      uid: uid,
      businessId: map['businessId'] as String? ?? '',
      businessType: map['businessType'] as String? ?? '',
      businessEmoji: map['businessEmoji'] as String? ?? '🏪',
      projectName: map['projectName'] as String? ?? '',
      is24Hours: map['is24Hours'] as bool? ?? false,
      hasInternalSeating: map['hasInternalSeating'] as bool? ?? false,
      hasCarService: map['hasCarService'] as bool? ?? false,
      hasExternalTables: map['hasExternalTables'] as bool? ?? false,
      dependsOnDelivery: _parseDelivery(map['dependsOnDelivery']),
      targetAudience: map['targetAudience'] as String? ?? '',
      area: map['area'] as String? ?? '',
      budget: map['budget'] as String? ?? '',
      nearbyLandmarks: map['nearbyLandmarks'] as String? ?? '',
      cafeType: map['cafeType'] as String?,
      restaurantType: map['restaurantType'] as String?,
      hasParking: map['hasParking'] as bool?,
      openingHours: map['opening_hours'] as String?,
      shopAge: map['shop_age'] as int?,
      score: (map['score'] as num?)?.toDouble(),
      aiBestNeighborhood: map['ai_best_neighborhood'] as String?,
      aiTopNeighborhoods: _parseTopNeighborhoods(map['ai_top_neighborhoods']),
      aiLatitude: (map['ai_latitude'] as num?)?.toDouble(),
      aiLongitude: (map['ai_longitude'] as num?)?.toDouble(),
      aiPredictedZone: map['ai_predicted_zone'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ─── إلى Map (للتوافق مع الشاشات القديمة) ───────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'businessId': businessId,
      'businessType': businessType,
      'businessEmoji': businessEmoji,
      'projectName': projectName,
      'is24Hours': is24Hours,
      'hasInternalSeating': hasInternalSeating,
      'hasCarService': hasCarService,
      'hasExternalTables': hasExternalTables,
      'dependsOnDelivery': dependsOnDelivery,
      'targetAudience': targetAudience,
      'area': area,
      'budget': budget,
      'nearbyLandmarks': nearbyLandmarks,
      if (cafeType != null) 'cafeType': cafeType,
      if (restaurantType != null) 'restaurantType': restaurantType,
      if (hasParking != null) 'hasParking': hasParking,
      if (openingHours != null) 'opening_hours': openingHours,
      if (shopAge != null) 'shop_age': shopAge,
      if (score != null) 'score': score,
      if (aiBestNeighborhood != null) 'ai_best_neighborhood': aiBestNeighborhood,
      if (aiTopNeighborhoods != null) 'ai_top_neighborhoods': aiTopNeighborhoods,
      if (aiLatitude != null) 'ai_latitude': aiLatitude,
      if (aiLongitude != null) 'ai_longitude': aiLongitude,
      if (aiPredictedZone != null) 'ai_predicted_zone': aiPredictedZone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProjectModel copyWith({double? score}) {
    return ProjectModel(
      id: id,
      uid: uid,
      businessId: businessId,
      businessType: businessType,
      businessEmoji: businessEmoji,
      projectName: projectName,
      is24Hours: is24Hours,
      hasInternalSeating: hasInternalSeating,
      hasCarService: hasCarService,
      hasExternalTables: hasExternalTables,
      dependsOnDelivery: dependsOnDelivery,
      targetAudience: targetAudience,
      area: area,
      budget: budget,
      nearbyLandmarks: nearbyLandmarks,
      cafeType: cafeType,
      restaurantType: restaurantType,
      hasParking: hasParking,
      openingHours: openingHours,
      shopAge: shopAge,
      score: score ?? this.score,
      aiBestNeighborhood: aiBestNeighborhood,
      aiTopNeighborhoods: aiTopNeighborhoods,
      aiLatitude: aiLatitude,
      aiLongitude: aiLongitude,
      aiPredictedZone: aiPredictedZone,
      createdAt: createdAt,
    );
  }
}
