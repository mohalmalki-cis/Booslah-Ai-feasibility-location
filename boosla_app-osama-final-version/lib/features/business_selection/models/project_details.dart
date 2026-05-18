class ProjectDetails {
  final String businessId;
  final String businessType;
  final String businessEmoji;
  final String projectName;

  // Common toggles
  final bool is24Hours;
  final bool hasInternalSeating;
  final bool hasCarService;
  final bool hasExternalTables;

  // depends_on_delivery_orders — Low / Medium / High (dataset values)
  final String dependsOnDelivery;

  // Common dropdowns
  final String targetAudience;
  final String area;
  final String budget;
  final String nearbyLandmarks;

  // Type-specific fields
  final String? cafeType;       // For cafes only (غير موجود في dataset — محفوظ للمستقبل)
  final String? restaurantType; // For restaurants only
  final bool? hasParking;       // For grocery only
  final String? openingHours;   // Morning / Evening / Both
  final int? shopAge;           // عمر المشروع بالسنوات (اختياري — يحسّن دقة الموديل)

  ProjectDetails({
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
    this.cafeType,
    this.restaurantType,
    this.hasParking,
    this.openingHours,
    this.shopAge,
  });

  // Convert to JSON for database/API
  Map<String, dynamic> toJson() {
    return {
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
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Convert to AI prompt format (جاهز للربط لاحقاً)
  String toAIPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('=== تفاصيل المشروع ===');
    buffer.writeln('نوع المشروع: $businessType');
    buffer.writeln('اسم المشروع: $projectName');
    buffer.writeln('');

    if (cafeType != null) {
      buffer.writeln('نوع المقهى: $cafeType');
    }
    if (restaurantType != null) {
      buffer.writeln('نوع المطعم: $restaurantType');
    }
    buffer.writeln('');

    buffer.writeln('=== الخصائص ===');
    buffer.writeln('ساعات العمل: ${is24Hours ? "24 ساعة" : "ساعات محددة"}');
    if (hasInternalSeating) buffer.writeln('✓ جلوس داخلي');
    if (hasCarService) buffer.writeln('✓ خدمة سيارات');
    if (hasExternalTables) buffer.writeln('✓ طاولات خارجية');
    buffer.writeln('الاعتماد على التوصيل: $dependsOnDelivery');
    if (hasParking ?? false) buffer.writeln('✓ مواقف سيارات');
    buffer.writeln('');

    buffer.writeln('=== التفاصيل ===');
    buffer.writeln('الفئة المستهدفة: $targetAudience');
    buffer.writeln('مساحة المحل: $area');
    buffer.writeln('الميزانية: $budget');
    buffer.writeln('المعالم القريبة: $nearbyLandmarks');
    if (shopAge != null) buffer.writeln('عمر المشروع: $shopAge سنة');

    return buffer.toString();
  }

  // From JSON (لاسترجاع البيانات من Database)
  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    return ProjectDetails(
      businessId: json['businessId'] as String,
      businessType: json['businessType'] as String,
      businessEmoji: json['businessEmoji'] as String,
      projectName: json['projectName'] as String,
      is24Hours: json['is24Hours'] as bool,
      hasInternalSeating: json['hasInternalSeating'] as bool,
      hasCarService: json['hasCarService'] as bool,
      hasExternalTables: json['hasExternalTables'] as bool,
      dependsOnDelivery: json['dependsOnDelivery'] is bool
          ? (json['dependsOnDelivery'] as bool ? 'High' : 'Low')
          : (json['dependsOnDelivery'] as String? ?? 'Low'),
      targetAudience: json['targetAudience'] as String,
      area: json['area'] as String,
      budget: json['budget'] as String,
      nearbyLandmarks: json['nearbyLandmarks'] as String,
      cafeType: json['cafeType'] as String?,
      restaurantType: json['restaurantType'] as String?,
      hasParking: json['hasParking'] as bool?,
      openingHours: json['opening_hours'] as String?,
      shopAge: json['shop_age'] as int?,
    );
  }
}
