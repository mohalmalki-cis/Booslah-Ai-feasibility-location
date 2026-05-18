// اختبارات الواجهة — الأسبوع الثامن
// تغطي المكونات الرئيسية: ScoreRing، AppErrorWidget، AppEmptyState، SkeletonCard

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boosla_app/shared/widgets/app_error_widget.dart';
import 'package:boosla_app/shared/widgets/loading_widget.dart';
import 'package:boosla_app/core/animations/fade_slide_widget.dart';
import 'package:boosla_app/features/dashboard/widgets/score_ring_widget.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────
/// يلف الويدجت بـ MaterialApp + Directionality عربية
Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  // ─── ScoreRingWidget Tests ─────────────────────────────────────────────────
  group('ScoreRingWidget', () {
    testWidgets('يعرض نتيجة 80 بتصنيف ممتاز', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScoreRingWidget(score: 80)));
      await tester.pump(const Duration(milliseconds: 1300));

      expect(find.text('ممتاز'), findsOneWidget);
    });

    testWidgets('يعرض نتيجة 60 بتصنيف جيد', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScoreRingWidget(score: 60)));
      await tester.pump(const Duration(milliseconds: 1300));

      expect(find.text('جيد'), findsOneWidget);
    });

    testWidgets('يعرض نتيجة 40 بتصنيف متوسط', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScoreRingWidget(score: 40)));
      await tester.pump(const Duration(milliseconds: 1300));

      expect(find.text('متوسط'), findsOneWidget);
    });

    testWidgets('يعرض نتيجة 20 بتصنيف ضعيف', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScoreRingWidget(score: 20)));
      await tester.pump(const Duration(milliseconds: 1300));

      expect(find.text('ضعيف'), findsOneWidget);
    });

    testWidgets('يُنشأ بدون خطأ مع حجم مخصص', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const ScoreRingWidget(score: 75, size: 180)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ─── AppErrorWidget Tests ──────────────────────────────────────────────────
  group('AppErrorWidget', () {
    testWidgets('يعرض رسالة الخطأ الافتراضية', (tester) async {
      await tester.pumpWidget(buildTestApp(const AppErrorWidget()));
      expect(find.text('حدث خطأ غير متوقع'), findsOneWidget);
    });

    testWidgets('يعرض رسالة خطأ مخصصة', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AppErrorWidget(message: 'فشل تحميل البيانات')),
      );
      expect(find.text('فشل تحميل البيانات'), findsOneWidget);
    });

    testWidgets('يعرض زر إعادة المحاولة ويعمل عند الضغط', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        buildTestApp(AppErrorWidget(onRetry: () => retried = true)),
      );
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, isTrue);
    });

    testWidgets('لا يعرض زر إعادة المحاولة بدون onRetry', (tester) async {
      await tester.pumpWidget(buildTestApp(const AppErrorWidget()));
      expect(find.text('إعادة المحاولة'), findsNothing);
    });

    testWidgets('يعرض التفاصيل عند تمريرها', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AppErrorWidget(
          message: 'خطأ',
          details: 'تحقق من الاتصال بالإنترنت',
        )),
      );
      expect(find.text('تحقق من الاتصال بالإنترنت'), findsOneWidget);
    });
  });

  // ─── AppEmptyState Tests ───────────────────────────────────────────────────
  group('AppEmptyState', () {
    testWidgets('يعرض العنوان والإيموجي', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppEmptyState(emoji: '📭', title: 'لا توجد مشاريع'),
        ),
      );
      expect(find.text('📭'), findsOneWidget);
      expect(find.text('لا توجد مشاريع'), findsOneWidget);
    });

    testWidgets('يعرض زر الإجراء ويعمل عند الضغط', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(AppEmptyState(
          emoji: '📭',
          title: 'لا توجد مشاريع',
          buttonLabel: 'أضف مشروعاً',
          onAction: () => tapped = true,
        )),
      );
      expect(find.text('أضف مشروعاً'), findsOneWidget);
      await tester.tap(find.text('أضف مشروعاً'));
      expect(tapped, isTrue);
    });

    testWidgets('لا يعرض الزر بدون buttonLabel', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AppEmptyState(emoji: '📭', title: 'فارغ')),
      );
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  // ─── SkeletonCard Tests ────────────────────────────────────────────────────
  group('SkeletonCard', () {
    testWidgets('يُنشأ بالأبعاد الافتراضية بدون خطأ', (tester) async {
      await tester.pumpWidget(buildTestApp(const SkeletonCard()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('يحترم الأبعاد المخصصة', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const SkeletonCard(height: 120, width: 200)),
      );
      final box = tester.renderObject<RenderBox>(find.byType(SkeletonCard));
      expect(box.size.height, equals(120));
      expect(box.size.width, equals(200));
    });
  });

  // ─── FadeSlideWidget Tests ─────────────────────────────────────────────────
  group('FadeSlideWidget', () {
    testWidgets('يعرض الـ child بعد انتهاء الأنيميشن', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const FadeSlideWidget(child: Text('مرحباً'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('مرحباً'), findsOneWidget);
    });

    testWidgets('يعمل مع delay بدون خطأ', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const FadeSlideWidget(
          delay: Duration(milliseconds: 100),
          child: Text('تأخير'),
        )),
      );
      await tester.pumpAndSettle();
      expect(find.text('تأخير'), findsOneWidget);
    });
  });

  // ─── AppLoadingWidget Tests ────────────────────────────────────────────────
  group('AppLoadingWidget', () {
    testWidgets('يعرض دائرة التحميل', (tester) async {
      await tester.pumpWidget(buildTestApp(const AppLoadingWidget()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('يعرض رسالة عند تمريرها', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AppLoadingWidget(message: 'جاري التحميل...')),
      );
      expect(find.text('جاري التحميل...'), findsOneWidget);
    });

    testWidgets('لا يعرض نصاً بدون message', (tester) async {
      await tester.pumpWidget(buildTestApp(const AppLoadingWidget()));
      expect(find.byType(Text), findsNothing);
    });
  });
}
