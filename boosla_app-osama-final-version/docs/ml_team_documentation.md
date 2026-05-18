# وثيقة تكامل نموذج الذكاء الاصطناعي — تطبيق بوصلة
> الإصدار: 1.0 | الأسبوع الرابع عشر | مشروع تخرج — جامعة الملك سعود

---

## نظرة عامة

تطبيق **بوصلة** يساعد رواد الأعمال على اختيار الموقع الأمثل لنشاطهم التجاري.
الموديل المطلوب: **تصنيف متعدد الفئات** يتنبأ بالموقع المناسب (حي / منطقة) بناءً على خصائص المشروع.

---

## 1. أنواع المشاريع المدعومة

| النوع (عربي) | المعرّف (إنجليزي) | الداتاسيت المقابل |
|---|---|---|
| مقهى | `cafe` | `cafes_with_scores.csv` |
| مطعم | `restaurant` | `restaurants_with_scores.csv` |
| بقالة | `grocery` | `supermarkets_with_scores.csv` |

---

## 2. هيكل البيانات المُدخلة (Input)

### 2.1 الحقول المشتركة لكل الأنواع

| اسم الحقل (JSON) | النوع | القيم المقبولة | ملاحظة |
|---|---|---|---|
| `business_type` | String | `cafe` / `restaurant` / `grocery` | إلزامي |
| `budget` | String | `Low` / `Medium` / `High` | إلزامي |
| `area` | String | `Small` / `Medium` / `Large` | إلزامي |
| `target_audience` | String | `Employees` / `Students` / `Mixed` / `Families` / `Youth` | إلزامي |
| `nearby_landmarks` | String | `School` / `Mall` / `Hospital` / `Mosque` / `Main Road` / `Inside Neighborhood` | إلزامي |
| `depends_on_delivery` | String | `Low` / `Medium` / `High` | إلزامي |
| `is_24_hours` | Boolean | `true` / `false` | إلزامي |
| `has_internal_seating` | Boolean | `true` / `false` | إلزامي |
| `has_car_service` | Boolean | `true` / `false` | إلزامي |
| `has_external_tables` | Boolean | `true` / `false` | إلزامي |
| `shop_age` | Integer (nullable) | 0-50 | اختياري — يُحسّن الدقة |

### 2.2 الحقول الإضافية للمطعم فقط

| اسم الحقل (JSON) | النوع | القيم المقبولة |
|---|---|---|
| `restaurant_type` | String (nullable) | `Fast Food` / `Traditional` / `International` |
| `opening_hours` | String (nullable) | `Morning` / `Evening` / `Both` |

### 2.3 الحقول الإضافية للبقالة فقط

| اسم الحقل (JSON) | النوع | القيم المقبولة |
|---|---|---|
| `has_parking` | Boolean (nullable) | `true` / `false` |
| `opening_hours` | String (nullable) | `Morning` / `Evening` / `Both` |

---

## 3. مثال طلب (Request Body)

### مقهى
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
  "has_external_tables": true,
  "shop_age": 2
}
```

### مطعم
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
  "opening_hours": "Both"
}
```

### بقالة
```json
{
  "business_type": "grocery",
  "budget": "Low",
  "area": "Small",
  "target_audience": "Mixed",
  "nearby_landmarks": "Inside Neighborhood",
  "depends_on_delivery": "Low",
  "is_24_hours": true,
  "has_internal_seating": false,
  "has_car_service": false,
  "has_external_tables": false,
  "has_parking": true,
  "opening_hours": "Both"
}
```

---

## 4. هيكل الاستجابة المتوقعة (Response)

```json
{
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
      "coordinates": { "latitude": 24.6986, "longitude": 46.6851 }
    },
    {
      "rank": 2,
      "district": "حي الملز",
      "score": 0.72,
      "coordinates": { "latitude": 24.6755, "longitude": 46.7214 }
    },
    {
      "rank": 3,
      "district": "حي السليمانية",
      "score": 0.65,
      "coordinates": { "latitude": 24.6901, "longitude": 46.6823 }
    }
  ],
  "model_version": "1.0.0",
  "business_type": "cafe"
}
```

### وصف حقول الاستجابة

| الحقل | النوع | الوصف |
|---|---|---|
| `predicted_location` | String | اسم الحي / المنطقة المتوقعة |
| `confidence` | Float (0.0–1.0) | مستوى الثقة في التنبؤ |
| `coordinates.latitude` | Float | خط العرض للموقع المتوقع |
| `coordinates.longitude` | Float | خط الطول للموقع المتوقع |
| `top_locations` | Array | أفضل 3 مواقع مقترحة مرتبة تنازلياً |
| `top_locations[].rank` | Integer | الترتيب (1 = الأفضل) |
| `top_locations[].district` | String | اسم الحي |
| `top_locations[].score` | Float | درجة الثقة (0.0–1.0) |
| `top_locations[].coordinates` | Object | إحداثيات الحي |
| `model_version` | String | إصدار الموديل |
| `business_type` | String | نوع النشاط التجاري (للتحقق) |

---

## 5. تعريف أعمدة الداتاسيت (مطابقة مع الفورم)

### cafes_with_scores.csv

| عمود الداتاسيت | حقل الفورم | نوع القيم |
|---|---|---|
| `budget` | `budget` | Low / Medium / High |
| `area_sqm_category` | `area` | Small / Medium / Large |
| `target_audience` | `target_audience` | Employees / Students / Mixed / Families / Youth |
| `nearby_landmark` | `nearby_landmarks` | School / Mall / Hospital / Mosque / Main Road / Inside Neighborhood |
| `depends_on_delivery_orders` | `depends_on_delivery` | Low / Medium / High |
| `is_24_hours` | `is_24_hours` | 0 / 1 |
| `has_internal_seating` | `has_internal_seating` | 0 / 1 |
| `has_car_service` | `has_car_service` | 0 / 1 |
| `has_external_tables` | `has_external_tables` | 0 / 1 |
| `shop_age` | `shop_age` | Integer (اختياري) |
| `location_score` | (الناتج) | Float |

### restaurants_with_scores.csv

| عمود الداتاسيت | حقل الفورم |
|---|---|
| `restaurant_type` | `restaurant_type` |
| `opening_hours` | `opening_hours` |
| (+ جميع الحقول المشتركة أعلاه) | |

### supermarkets_with_scores.csv

| عمود الداتاسيت | حقل الفورم |
|---|---|
| `has_parking` | `has_parking` |
| `opening_hours` | `opening_hours` |
| (+ جميع الحقول المشتركة أعلاه) | |

---

## 6. الموقع المؤقت لعرض النتيجة (Flutter)

الـ Widget الجاهز لعرض الموقع المتوقع موجود في:
```
lib/features/dashboard/widgets/predicted_location_widget.dart
```

يقبل الـ Widget حالياً نقطة إحداثيات (`LatLng`) وعنوان نصي.
عند ربط الـ API استبدل البيانات الثابتة بالاستجابة القادمة من الموديل.

---

## 7. ملاحظات مهمة للموديل

- **البيانات مخزّنة بالإنجليزية** في Firestore وتُعرض بالعربية في الواجهة. أرسل القيم الإنجليزية دائماً.
- **`depends_on_delivery`** كان سابقاً `bool` في النظام — تأكد من تحويله إلى `Low/Medium/High` عند المعالجة.
- **`shop_age`** اختياري؛ يُحسّن دقة التنبؤ لكنه ليس شرطاً.
- **الدرجة الحالية** (`score`) في التطبيق هي حساب محلي مؤقت وستُستبدل بالدرجة القادمة من الموديل.

---

*آخر تحديث: الأسبوع الرابع عشر | فريق بوصلة — جامعة الملك سعود*
