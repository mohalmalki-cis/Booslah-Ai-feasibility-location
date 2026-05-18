# متطلبات الـ API — تطبيق بوصلة
> الإصدار: 1.0 | الأسبوع الرابع عشر | مشروع تخرج — جامعة الملك سعود

---

## 1. نظرة عامة

يحتاج تطبيق بوصلة إلى **نقطة نهاية API واحدة** (Endpoint) تستقبل خصائص المشروع التجاري وتُعيد توقّعاً بأفضل الأحياء / المواقع المناسبة لافتتاح النشاط.

---

## 2. المواصفات التقنية

### 2.1 نقطة النهاية

```
POST /api/v1/predict-location
```

### 2.2 Headers المطلوبة

```
Content-Type: application/json
Authorization: Bearer <API_KEY>
```

### 2.3 HTTP Method

`POST`

---

## 3. Request Body

### الحقول الإلزامية

```json
{
  "business_type": "cafe",
  "budget": "Medium",
  "area": "Medium",
  "target_audience": "Youth",
  "nearby_landmarks": "Mall",
  "depends_on_delivery": "Low",
  "is_24_hours": false,
  "has_internal_seating": true,
  "has_car_service": false,
  "has_external_tables": true
}
```

### الحقول الاختيارية (تُحسّن دقة التنبؤ)

```json
{
  "shop_age": 3,
  "restaurant_type": "Traditional",
  "opening_hours": "Both",
  "has_parking": false
}
```

### مثال كامل (مطعم)

```json
{
  "business_type": "restaurant",
  "budget": "High",
  "area": "Large",
  "target_audience": "Families",
  "nearby_landmarks": "Main Road",
  "depends_on_delivery": "High",
  "is_24_hours": false,
  "has_internal_seating": true,
  "has_car_service": true,
  "has_external_tables": false,
  "restaurant_type": "Traditional",
  "opening_hours": "Both",
  "shop_age": 5
}
```

---

## 4. Response (استجابة ناجحة — HTTP 200)

```json
{
  "status": "success",
  "predicted_location": "حي العليا",
  "confidence": 0.87,
  "coordinates": {
    "latitude": 24.6986,
    "longitude": 46.6851
  },
  "top_locations": [
    {
      "rank": 1,
      "district": "حي العليا",
      "score": 0.87,
      "coordinates": {
        "latitude": 24.6986,
        "longitude": 46.6851
      }
    },
    {
      "rank": 2,
      "district": "حي الملز",
      "score": 0.72,
      "coordinates": {
        "latitude": 24.6755,
        "longitude": 46.7214
      }
    },
    {
      "rank": 3,
      "district": "حي السليمانية",
      "score": 0.65,
      "coordinates": {
        "latitude": 24.6901,
        "longitude": 46.6823
      }
    }
  ],
  "model_version": "1.0.0",
  "business_type": "restaurant"
}
```

---

## 5. Response (استجابة خطأ)

### خطأ في المدخلات (HTTP 422)
```json
{
  "status": "error",
  "error_code": "VALIDATION_ERROR",
  "message": "حقل business_type مطلوب",
  "field": "business_type"
}
```

### خطأ في المصادقة (HTTP 401)
```json
{
  "status": "error",
  "error_code": "UNAUTHORIZED",
  "message": "مفتاح API غير صالح أو منتهي الصلاحية"
}
```

### خطأ في الخادم (HTTP 500)
```json
{
  "status": "error",
  "error_code": "INTERNAL_ERROR",
  "message": "حدث خطأ أثناء معالجة الطلب"
}
```

---

## 6. القيم المقبولة لكل حقل

| الحقل | القيم المقبولة |
|---|---|
| `business_type` | `cafe`, `restaurant`, `grocery` |
| `budget` | `Low`, `Medium`, `High` |
| `area` | `Small`, `Medium`, `Large` |
| `target_audience` | `Employees`, `Students`, `Mixed`, `Families`, `Youth` |
| `nearby_landmarks` | `School`, `Mall`, `Hospital`, `Mosque`, `Main Road`, `Inside Neighborhood` |
| `depends_on_delivery` | `Low`, `Medium`, `High` |
| `restaurant_type` | `Fast Food`, `Traditional`, `International` |
| `opening_hours` | `Morning`, `Evening`, `Both` |

---

## 7. متطلبات الأداء

| المعيار | الحد المطلوب |
|---|---|
| زمن الاستجابة (Response Time) | أقل من 3 ثوان |
| التوفر (Availability) | 99% |
| الطلبات المتزامنة | تدعم 50 طلباً في الوقت ذاته |
| انتهاء صلاحية الطلب (Timeout) | 10 ثوان |

---

## 8. متطلبات الأمان

- يجب أن يكون الـ API متاحاً عبر **HTTPS فقط**.
- مفاتيح الـ API تُخزَّن في Firestore ولا تُكتب في الكود مباشرةً.
- يجب إضافة **Rate Limiting**: لا يزيد عن 100 طلب / ساعة لكل مستخدم.
- يجب تسجيل كل الطلبات (Request Logging) لأغراض التتبع.

---

## 9. كيفية الربط في Flutter

### الموقع الحالي للـ Widget

```
lib/features/dashboard/widgets/predicted_location_widget.dart
```

### الخطوات المطلوبة للربط

1. إنشاء `lib/core/services/ai_service.dart`
2. إضافة دالة `predictLocation(Map<String, dynamic> projectData)` تستدعي الـ API
3. استدعاء الدالة من `analysis_result_screen.dart` عند فتح الشاشة
4. تمرير الإحداثيات القادمة من الـ API إلى `PredictedLocationWidget`

### مثال كود Flutter (مقترح)

```dart
// lib/core/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  static const String _baseUrl = 'https://your-api-url.com/api/v1';
  static const String _apiKey = 'YOUR_API_KEY'; // استخدم env variable

  Future<Map<String, dynamic>> predictLocation(
    Map<String, dynamic> projectData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predict-location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'business_type': projectData['businessType'] ?? '',
        'budget': projectData['budget'] ?? '',
        'area': projectData['area'] ?? '',
        'target_audience': projectData['targetAudience'] ?? '',
        'nearby_landmarks': projectData['nearbyLandmarks'] ?? '',
        'depends_on_delivery': projectData['dependsOnDelivery'] ?? 'Low',
        'is_24_hours': projectData['is24Hours'] ?? false,
        'has_internal_seating': projectData['hasInternalSeating'] ?? false,
        'has_car_service': projectData['hasCarService'] ?? false,
        'has_external_tables': projectData['hasExternalTables'] ?? false,
        if (projectData['shop_age'] != null) 'shop_age': projectData['shop_age'],
        if (projectData['restaurantType'] != null)
          'restaurant_type': projectData['restaurantType'],
        if (projectData['opening_hours'] != null)
          'opening_hours': projectData['opening_hours'],
        if (projectData['hasParking'] != null)
          'has_parking': projectData['hasParking'],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('فشل الاتصال بالموديل: ${response.statusCode}');
  }
}
```

---

## 10. تحويل أسماء الحقول (Flutter → API)

| اسم الحقل في Flutter (Firestore) | اسم الحقل في API |
|---|---|
| `businessType` | `business_type` |
| `targetAudience` | `target_audience` |
| `nearbyLandmarks` | `nearby_landmarks` |
| `dependsOnDelivery` | `depends_on_delivery` |
| `is24Hours` | `is_24_hours` |
| `hasInternalSeating` | `has_internal_seating` |
| `hasCarService` | `has_car_service` |
| `hasExternalTables` | `has_external_tables` |
| `restaurantType` | `restaurant_type` |
| `opening_hours` | `opening_hours` |
| `shop_age` | `shop_age` |
| `hasParking` | `has_parking` |

---

*آخر تحديث: الأسبوع الرابع عشر | فريق بوصلة — جامعة الملك سعود*
