import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectAdvice {
  final int number;
  final String text;
  const ProjectAdvice({required this.number, required this.text});
}

class ProjectAdviceService {
  ProjectAdviceService._();
  static final ProjectAdviceService _instance = ProjectAdviceService._();
  factory ProjectAdviceService() => _instance;

  static const _apiKey =
      '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';
  static const _model = 'claude-haiku-4-5-20251001';
  static const _url = 'https://api.anthropic.com/v1/messages';

  static const _systemPrompt = '''
أنت مستشار أعمال خبير متخصص في المشاريع التجارية السعودية.

مهمتك: قراءة بيانات المشروع الفعلية وتوليد 4 توصيات مختلفة تماماً لكل مشروع.

قواعد صارمة:
- كل توصية يجب أن تذكر اسم المشروع أو نوعه أو جمهوره أو ميزانيته بشكل صريح
- لا توصيات عامة تصلح لأي مشروع — كل جملة مرتبطة ببيانات هذا المشروع تحديداً
- إذا كان المشروع مقهى: ركّز على القهوة والتصميم وتجربة العميل والمنافسة
- إذا كان المطعم: ركّز على القائمة والتوصيل والتميّز والمنطقة
- إذا كانت البقالة: ركّز على المخزون والسعر والولاء والموقع
- إذا كان الجمهور طلاباً: اذكر استراتيجيات تناسب الطلاب تحديداً
- إذا كان الجمهور عائلات: اذكر ما يناسب العائلات
- إذا كانت الميزانية منخفضة: توصيات توفيرية وذكية
- إذا كانت الميزانية عالية: توصيات استثمارية وتوسعية
- إذا كان يعتمد على التوصيل: توصية واحدة على الأقل عن تحسين التوصيل
- إذا كان به كار سيرفس: اذكره في إحدى التوصيات
- التوصيات يجب أن تبدأ بفعل أمر: (اختر، استثمر، ابدأ، فكّر، حسّن، ركّز، استغل، طوّر)

ردّ بـ JSON نظيف فقط بدون Markdown:
{
  "advice": [
    { "number": 1, "text": "توصية مخصصة تذكر تفاصيل المشروع" },
    { "number": 2, "text": "توصية مخصصة تذكر تفاصيل المشروع" },
    { "number": 3, "text": "توصية مخصصة تذكر تفاصيل المشروع" },
    { "number": 4, "text": "توصية مخصصة تذكر تفاصيل المشروع" }
  ]
}
''';

  String _buildUserMessage(Map<String, dynamic> p) {
    return '''
بيانات المشروع الكاملة — ولّد توصيات مخصصة بناءً على هذه البيانات فقط:

- اسم المشروع: ${p['projectName'] ?? p['businessName'] ?? 'غير محدد'}
- نوع المشروع: ${p['businessType'] ?? 'غير محدد'}
- التخصص: ${p['cafeType'] ?? p['restaurantType'] ?? 'لا يوجد'}
- الجمهور المستهدف: ${p['targetAudience'] ?? 'غير محدد'}
- الميزانية: ${p['budget'] ?? 'غير محددة'}
- المساحة: ${p['area'] ?? 'غير محددة'}
- يعمل 24 ساعة: ${p['is24Hours'] == true ? 'نعم' : 'لا'}
- مقاعد داخلية: ${p['hasInternalSeating'] == true ? 'نعم' : 'لا'}
- كار سيرفس: ${p['hasCarService'] == true ? 'نعم' : 'لا'}
- طاولات خارجية: ${p['hasExternalTables'] == true ? 'نعم' : 'لا'}
- يعتمد على التوصيل: ${p['dependsOnDelivery'] == true ? 'نعم' : 'لا'}
- موقف سيارات: ${p['hasParking'] == true ? 'نعم' : 'لا'}

المطلوب: 4 توصيات تذكر تفاصيل هذا المشروع بالاسم أو النوع أو الجمهور. لا توصيات عامة.
''';
  }

  Future<List<ProjectAdvice>> getAdvice(
      Map<String, dynamic> projectData) async {
    print('=== PROJECT DATA RECEIVED ===');
    print(projectData.toString());
    final userMessage = _buildUserMessage(projectData);

    final response = await http
        .post(
          Uri.parse(_url),
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'max_tokens': 1000,
            'system': _systemPrompt,
            'messages': [
              {'role': 'user', 'content': userMessage},
            ],
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    var content =
        (decoded['content'] as List).first['text'] as String;

    // Strip ```json fences if present
    content = content
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .trim();

    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final adviceList = parsed['advice'] as List;
    return adviceList
        .map((e) => ProjectAdvice(
              number: (e['number'] as num).toInt(),
              text: e['text'] as String,
            ))
        .toList();
  }
}
