import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../widgets/score_ring_widget.dart';
import '../widgets/predicted_location_widget.dart';
import '../widgets/ai_advice_widget.dart';

/// شاشة نتيجة تحليل المشروع — الأسبوع السادس
/// تستقبل بيانات المشروع من LocalStorage وتعرض التحليل
/// جاهزة للربط مع نموذج الذكاء الاصطناعي لاحقاً
class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> project;

  const AnalysisResultScreen({super.key, required this.project});

  // ─── حساب النتيجة — يستخدم السكور المحفوظ أولاً لضمان التطابق مع بقية الشاشات
  double _calcOverallScore() {
    // استخدم السكور المحفوظ إذا كان موجوداً وغير صفري
    final saved = project['score'];
    if (saved != null && (saved as num).toDouble() > 0) {
      return (saved).toDouble();
    }

    // fallback: احسب يدوياً (يدعم الإنجليزي والعربي القديم)
    double score = 60.0;
    final budget = project['budget'] as String? ?? '';
    if (budget == 'High' || budget.contains('أكثر')) {
      score += 12;
    } else if (budget == 'Medium' || budget.contains('500'))
      score += 8;
    else if (budget == 'Low' || budget.contains('200'))
      score += 5;

    final area = project['area'] as String? ?? '';
    if (area == 'Large' || area.contains('كبير') || area.contains('200')) {
      score += 8;
    } else if (area == 'Medium' || area.contains('100'))
      score += 5;

    if (project['is24Hours'] == true) score += 3;
    if (project['hasInternalSeating'] == true) score += 3;
    if (project['hasCarService'] == true) score += 3;
    if (project['hasExternalTables'] == true) score += 2;
    if (project['hasParking'] == true) score += 2;
    if (project['dependsOnDelivery'] == 'High') {
      score += 3;
    } else if (project['dependsOnDelivery'] == 'Medium')
      score += 2;

    final age = project['shop_age'] as int?;
    if (age != null) {
      if (age >= 5) {
        score += 3;
      } else if (age >= 2)
        score += 1;
    }
    return score.clamp(0.0, 100.0);
  }

  // ─── عوامل التقييم ────────────────────────────────────────────────────────
  // تختلف لكل مشروع بناءً على ميزاته الفعلية + توافقها مع المنطقة المقترحة
  List<Map<String, dynamic>> _calcFactors() {
    final budget = project['budget'] as String? ?? '';
    final area = project['area'] as String? ?? '';
    final target = project['targetAudience'] as String? ?? '';
    final type = project['businessType'] as String? ?? '';

    // تنويع بسيط حسب اسم المشروع — يخلق فروقات صغيرة بين مشاريع متشابهة
    final seed = (project['projectName'] as String? ?? 'x').hashCode.abs();
    int j(int range) => (seed + range) % 9 - 4; // -4..+4

    // ─── الميزانية (٤ مستويات + jitter) ────────────────────────────
    double budgetScore = 55.0 + j(1);
    if (budget == 'High' || budget.contains('أكثر')) {
      budgetScore = 88.0 + j(2);
    } else if (budget == 'Medium' || budget.contains('500')) {
      budgetScore = 70.0 + j(3);
    } else if (budget == 'Low' || budget.contains('200')) {
      budgetScore = 56.0 + j(4);
    }
    budgetScore = budgetScore.clamp(40.0, 96.0);

    // ─── المساحة ──────────────────────────────────────────────────
    double areaScore = 55.0 + j(5);
    if (area == 'Large' || area.contains('كبير') || area.contains('200')) {
      areaScore = 84.0 + j(6);
    } else if (area == 'Medium' || area.contains('100')) {
      areaScore = 68.0 + j(7);
    } else if (area == 'Small' || area.contains('صغير')) {
      areaScore = 52.0 + j(8);
    }
    areaScore = areaScore.clamp(40.0, 95.0);

    // ─── الخدمات (يعتمد على عدد الميزات + توافقها مع النوع) ────────
    int services = 0;
    if (project['is24Hours'] == true) services++;
    if (project['hasInternalSeating'] == true) services++;
    if (project['hasCarService'] == true) services++;
    if (project['hasExternalTables'] == true) services++;
    final raw = project['dependsOnDelivery'];
    final delivery = raw is bool
        ? (raw ? 'High' : 'Low')
        : (raw as String? ?? 'Low');
    if (delivery == 'High') services += 2;
    if (delivery == 'Medium') services++;
    if (project['hasParking'] == true) services++;
    double serviceScore = (48.0 + services * 6 + j(9)).clamp(40.0, 95.0);

    // ─── الجمهور المستهدف (متنوّع حسب الفئة + النوع) ───────────────
    double audienceScore = 65.0 + j(10);
    if (target == 'Families' || target.contains('عائ')) {
      audienceScore = type.contains('مطعم') ? 86.0 + j(11) : 74.0 + j(12);
    } else if (target == 'Students' || target.contains('طلاب')) {
      audienceScore = type.contains('مقهى') ? 88.0 + j(13) : 72.0 + j(14);
    } else if (target == 'Youth' || target.contains('شباب')) {
      audienceScore = 82.0 + j(15);
    } else if (target == 'Employees' || target.contains('موظف')) {
      audienceScore = 78.0 + j(16);
    } else if (target == 'Mixed' || target.contains('متنوع')) {
      audienceScore = 70.0 + j(17);
    }
    audienceScore = audienceScore.clamp(40.0, 95.0);

    // ─── عامل خامس: توافق الموقع (من نتيجة الـ AI) ────────────────
    final overallScore = (project['score'] as num?)?.toDouble() ?? 65.0;
    double locationFit = (overallScore - 5 + j(18)).clamp(45.0, 92.0);

    return [
      {
        'label': 'الميزانية',
        'icon': Icons.attach_money,
        'score': budgetScore,
        'detail': budget.isEmpty ? 'غير محدد' : budget,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'المساحة',
        'icon': Icons.square_foot,
        'score': areaScore,
        'detail': area.isEmpty ? 'غير محدد' : area,
        'color': const Color(0xFF3B82F6),
      },
      {
        'label': 'الخدمات',
        'icon': Icons.room_service_outlined,
        'score': serviceScore,
        'detail': '$services خدمات مفعّلة',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'label': 'الجمهور المستهدف',
        'icon': Icons.people_outline,
        'score': audienceScore,
        'detail': target.isEmpty ? 'غير محدد' : target,
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'توافق الموقع',
        'icon': Icons.location_on,
        'score': locationFit,
        'detail': _getBestNeighborhood(),
        'color': const Color(0xFFEF4444),
      },
    ];
  }

  // ─── توصيات الـ AI (Placeholder — سيُربط لاحقاً) ─────────────────────────
  List<String> _getRecommendations() {
    final type = project['businessType'] as String? ?? '';
    final List<String> recs = [
      'اختر موقعاً بالقرب من مراكز التسوق أو الجامعات لزيادة حركة العملاء.',
      'استثمر في تصميم داخلي مميز يعكس هوية مشروعك ويجذب وسائل التواصل الاجتناعي.',
      'ابدأ بحملات تسويقية عبر انستقرام وسناب شات قبل الافتتاح بشهر على الأقل.',
    ];
    if (type.contains('مقهى')) {
      recs.add('فكر في إضافة قائمة موسمية لتجديد تجربة العملاء بشكل دوري.');
    } else if (type.contains('مطعم')) {
      recs.add(
        'الاهتمام بسرعة الخدمة في أوقات الذروة يرفع رضا العملاء بشكل ملحوظ.',
      );
    } else {
      recs.add('نظام نقاط الولاء يزيد تكرار الزيارات بنسبة تصل إلى 30%.');
    }
    return recs;
  }

  // ─── إحداثيات الموقع المتوقع من الذكاء الاصطناعي ──────────────────────
  LatLng? _aiLatLng() {
    final lat = project['ai_latitude'];
    final lng = project['ai_longitude'];
    if (lat is num && lng is num) return LatLng(lat.toDouble(), lng.toDouble());
    return null;
  }

  // ─── أنسب حي — يقرأ نتيجة الذكاء الاصطناعي إذا متوفرة، وإلا fallback ──────
  String _getBestNeighborhood() {
    final aiBest = project['ai_best_neighborhood'] as String?;
    if (aiBest != null && aiBest.isNotEmpty) return aiBest;

    final type = project['businessType'] as String? ?? '';
    if (type.contains('مقهى') || type.contains('café') || type.contains('cafe')) {
      return 'حي النزهة';
    } else if (type.contains('مطعم') || type.contains('restaurant')) {
      return 'حي الملقا';
    }
    return 'حي العليا';
  }

  // ─── أفضل 3 أحياء — يقرأ من الذكاء الاصطناعي أولاً ────────────────────────
  List<Map<String, dynamic>> _getTop3Neighborhoods() {
    final aiTop = project['ai_top_neighborhoods'] as List?;
    if (aiTop != null && aiTop.isNotEmpty) {
      return aiTop
          .whereType<Map>()
          .map((e) => {
                'name': '${e['name'] ?? ''}',
                'percent': (e['percent'] is num)
                    ? (e['percent'] as num).toInt()
                    : 0,
              })
          .toList();
    }

    final type = project['businessType'] as String? ?? '';
    if (type.contains('مقهى') || type.contains('café')) {
      return [
        {'name': 'حي النزهة', 'percent': 92},
        {'name': 'حي الروضة', 'percent': 87},
        {'name': 'حي العزيزية', 'percent': 81},
      ];
    } else if (type.contains('مطعم')) {
      return [
        {'name': 'حي الملقا', 'percent': 89},
        {'name': 'حي السليمانية', 'percent': 84},
        {'name': 'حي العليا', 'percent': 79},
      ];
    }
    return [
      {'name': 'حي الربوة', 'percent': 88},
      {'name': 'حي الوادي', 'percent': 83},
      {'name': 'حي المروج', 'percent': 77},
    ];
  }

  // ─── عدد المنافسين (يتنوّع لكل مشروع حسب النوع + الميزانية + الموقع) ────
  int _getCompetitorCount() {
    final type = project['businessType'] as String? ?? '';
    int base = 8;
    if (type.contains('مقهى')) {
      base = 14;
    } else if (type.contains('مطعم')) base = 22;

    // المناطق التجاريّة فيها منافسين أكثر
    final zone = (project['ai_predicted_zone'] as String? ?? '').toLowerCase();
    int zoneAdj = 0;
    if (zone.contains('olaya') || zone.contains('malqa')) {
      zoneAdj = 6;
    } else if (zone.contains('rimal') || zone.contains('manakh')) zoneAdj = -3;

    // الميزانية العالية = أحياء فاخرة فيها منافسين أكثر
    final budget = project['budget'] as String? ?? '';
    int budgetAdj = 0;
    if (budget == 'High') {
      budgetAdj = 4;
    } else if (budget == 'Low') budgetAdj = -3;

    final jitter = _j(401, 4); // ±4
    return (base + zoneAdj + budgetAdj + jitter).clamp(3, 35);
  }

  // ─── متوسط تقييم المنافسين ────────────────────────────────────────────────
  double _getAvgCompetitorRating() {
    final ratings = _getCompetitorRatings();
    final sum = ratings.fold<double>(0, (a, b) => a + b);
    return (sum / ratings.length).clamp(2.5, 4.9);
  }

  @override
  Widget build(BuildContext context) {
    final score = _calcOverallScore();
    final factors = _calcFactors();
    final recs = _getRecommendations();
    final bestNeighborhood = _getBestNeighborhood();
    final top3 = _getTop3Neighborhoods();
    final competitorCount = _getCompetitorCount();
    final avgRating = _getAvgCompetitorRating();

    // ── Pie chart slices based on business type ──────────────────────────────
    final pieData = _getPieData(project['businessType'] as String? ?? '');

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            project['projectName'] ?? 'نتيجة التحليل',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: context.cs.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${project['businessEmoji'] ?? '🏪'}  ${project['businessType'] ?? ''}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.cs.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // ── Subtitle: أنسب حي ──────────────────────────
                          Text(
                            'أنسب حي: $bestNeighborhood',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.cs.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // زر الرجوع للصفحة الرئيسية مباشرة (يتجاوز الشاشات الوسيطة)
                    IconButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      icon: Icon(
                        Icons.home_outlined,
                        color: context.cs.primaryText,
                        size: 24,
                      ),
                      tooltip: 'الصفحة الرئيسية',
                    ),
                  ],
                ),
              ),

              // ─── Content ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ── Score Ring ──────────────────────────────────────
                      _buildScoreCard(context, score, competitorCount),

                      const SizedBox(height: 24),

                      // ── الموقع المقترح من الذكاء الاصطناعي ─────────────
                      PredictedLocationWidget(
                        predictedLocation: _aiLatLng(),
                        neighborhoodName: bestNeighborhood,
                      ),

                      const SizedBox(height: 24),

                      // ── Factors ─────────────────────────────────────────
                      _buildSectionTitle('📊 عوامل التقييم'),
                      const SizedBox(height: 12),
                      ...factors.map((f) => _buildFactorCard(context, f)),

                      const SizedBox(height: 24),

                      // ── أنسب 3 أحياء ────────────────────────────────────
                      _buildSectionTitle('🏘️ أنسب 3 أحياء'),
                      const SizedBox(height: 12),
                      _buildNeighborhoodsSection(context, top3),

                      const SizedBox(height: 24),

                      // ── إحصائيات المنافسين ────────────────────────────────
                      _buildSectionTitle('📊 إحصائيات المنافسين'),
                      const SizedBox(height: 12),
                      _buildCompetitorStats(
                          context, competitorCount, avgRating, pieData),

                      const SizedBox(height: 24),

                      // ── AI Advice (live API) ─────────────────────────────
                      AiAdviceWidget(projectData: project),

                      const SizedBox(height: 24),

                      // ── AI Recommendation ────────────────────────────────
                      _buildSectionTitle('🤖 توصيات الذكاء الاصطناعي'),
                      const SizedBox(height: 12),
                      _buildRecommendationCard(context, recs),

                      const SizedBox(height: 16),

                      // ── AI Badge ─────────────────────────────────────────
                      _buildAiBadge(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Score Card ───────────────────────────────────────────────────────────

  Widget _buildScoreCard(
      BuildContext context, double score, int competitorCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الدائرة الكبيرة
          ScoreRingWidget(score: score, size: 200),

          const SizedBox(height: 20),

          // شريط تلخيص سريع — الميزانية | المساحة | عدد المنافسين
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat(context, 'الميزانية', _budgetLabel()),
              _buildDivider(context),
              _buildQuickStat(
                  context, 'المساحة', project['area'] ?? '—'),
              _buildDivider(context),
              _buildQuickStat(
                  context, 'عدد المنافسين', '$competitorCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: context.cs.primaryText,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: context.cs.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(width: 1, height: 32, color: context.cs.border);
  }

  String _budgetLabel() {
    final b = project['budget'] as String? ?? '';
    if (b.isEmpty) return '—';
    // اختصر النص لو كان طويل
    if (b.length > 12) return '${b.substring(0, 12)}...';
    return b;
  }

  // ─── Section Title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) => Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            color: context.cs.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── Factor Card ──────────────────────────────────────────────────────────

  Widget _buildFactorCard(BuildContext context, Map<String, dynamic> factor) {
    final double score = (factor['score'] as num).toDouble();
    final Color color = factor['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // الصف العلوي: الاسم + الأيقونة + الدرجة
          Row(
            children: [
              // درجة مئوية
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${score.toInt()}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // الاسم
              Text(
                factor['label'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.cs.textPrimary,
                ),
              ),

              const SizedBox(width: 8),

              // أيقونة
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(factor['icon'] as IconData, color: color, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: context.cs.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 6),

          // التفصيل
          Text(
            factor['detail'] as String,
            style: AppTextStyles.caption.copyWith(
              color: context.cs.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  // ─── Neighborhoods Section ────────────────────────────────────────────────

  Widget _buildNeighborhoodsSection(
      BuildContext context, List<Map<String, dynamic>> neighborhoods) {
    final List<Color> chipColors = [
      AppColors.primary,
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: neighborhoods.asMap().entries.map((entry) {
          final idx = entry.key;
          final n = entry.value;
          final color = chipColors[idx % chipColors.length];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${n['percent']}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n['name'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: context.cs.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Pie Chart Data by Business Type ─────────────────────────────────────

  // ─── Hash seed مستقر لكل مشروع لتنويع الرسومات ────────────────────────
  int get _seed => (project['projectName'] as String? ?? 'x').hashCode.abs();
  int _j(int salt, int range) => ((_seed + salt) % (range * 2 + 1)) - range;

  // ─── تقييمات منافسين متنوّعة لكل مشروع ─────────────────────────────────
  List<double> _getCompetitorRatings() {
    final base = [4.0, 3.7, 4.3, 3.4, 4.1];
    return List.generate(5, (i) {
      final variation = _j(i + 100, 6) * 0.1; // ±0.6
      return (base[i] + variation).clamp(2.5, 4.9);
    });
  }

  // ─── منحنى نمو متوقّع مختلف لكل مشروع ──────────────────────────────────
  List<FlSpot> _getGrowthSpots() {
    final overall = (project['score'] as num?)?.toDouble() ?? 70.0;
    // نقطة البداية أقل من النتيجة، والنقطة النهائية أعلى منها بقليل
    final start = (overall * 0.35 + _j(200, 5)).clamp(15.0, 45.0);
    final end = (overall * 1.05 + _j(201, 5)).clamp(60.0, 98.0);
    final step = (end - start) / 5;
    return List.generate(6, (i) {
      final ideal = start + step * i;
      final wobble = _j(202 + i, 4).toDouble(); // ±4
      return FlSpot(i.toDouble(), (ideal + wobble).clamp(0.0, 100.0));
    });
  }

  PieChartSectionData _pie(double v, String label, Color color) =>
      PieChartSectionData(
        value: v,
        title: '$label\n${v.toInt()}%',
        color: color,
        radius: 55,
        titleStyle: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

  List<PieChartSectionData> _getPieData(String businessType) {
    // كل مشروع له توزيع سوق مختلف قليلاً
    double a, b, c, d;
    if (businessType.contains('مقهى') ||
        businessType.contains('café') ||
        businessType.contains('cafe')) {
      a = (35 + _j(301, 5)).toDouble(); // قهوة متخصصة
      b = (28 + _j(302, 4)).toDouble(); // مقهى تقليدي
      c = (22 + _j(303, 4)).toDouble(); // عصائر
      d = (100 - a - b - c).clamp(8.0, 25.0); // مخبوزات
      return [
        _pie(a, 'قهوة متخصصة', const Color(0xFF3B82F6)),
        _pie(b, 'مقهى تقليدي', const Color(0xFF10B981)),
        _pie(c, 'عصائر', const Color(0xFFF59E0B)),
        _pie(d, 'مخبوزات', const Color(0xFFEF4444)),
      ];
    } else if (businessType.contains('مطعم') ||
        businessType.contains('restaurant')) {
      a = (38 + _j(311, 5)).toDouble(); // وجبات سريعة
      b = (30 + _j(312, 4)).toDouble(); // مطبخ عربي
      c = (20 + _j(313, 4)).toDouble(); // مأكولات بحرية
      d = (100 - a - b - c).clamp(6.0, 20.0); // آسيوي
      return [
        _pie(a, 'وجبات سريعة', const Color(0xFF3B82F6)),
        _pie(b, 'مطبخ عربي', const Color(0xFF10B981)),
        _pie(c, 'مأكولات بحرية', const Color(0xFFF59E0B)),
        _pie(d, 'آسيوي', const Color(0xFFEF4444)),
      ];
    } else {
      a = (45 + _j(321, 5)).toDouble(); // سوبرماركت
      b = (30 + _j(322, 4)).toDouble(); // متوسط
      c = (100 - a - b).clamp(15.0, 35.0); // بقالة صغيرة
      return [
        _pie(a, 'سوبرماركت', const Color(0xFF3B82F6)),
        _pie(b, 'متوسط', const Color(0xFF10B981)),
        _pie(c, 'بقالة صغيرة', const Color(0xFFF59E0B)),
      ];
    }
  }

  // ─── Competitor Statistics Section ────────────────────────────────────────

  Widget _buildCompetitorStats(BuildContext context, int competitorCount,
      double avgRating, List<PieChartSectionData> pieData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Stat summary row ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cs.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.cs.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                context,
                'عدد المنافسين',
                '$competitorCount',
                const Color(0xFF3B82F6),
              ),
              Container(width: 1, height: 40, color: context.cs.border),
              _buildStatChip(
                context,
                'متوسط التقييم',
                '$avgRating نجوم',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Bar Chart: تقييمات المنافسين ─────────────────────────────────
        _buildChartCard(
          context,
          title: 'تقييمات المنافسين',
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: context.cs.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          'منافس 1',
                          'منافس 2',
                          'منافس 3',
                          'منافس 4',
                          'منافس 5',
                        ];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[idx],
                            style: TextStyle(
                              color: context.cs.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.cs.border,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: () {
                  final r = _getCompetitorRatings();
                  final colors = [
                    AppColors.primary,
                    const Color(0xFF10B981),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFF59E0B),
                    const Color(0xFFEF4444),
                  ];
                  return List.generate(
                    5,
                    (i) => _barGroup(i, r[i], colors[i]),
                  );
                }(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Pie Chart: توزيع السوق ────────────────────────────────────────
        _buildChartCard(
          context,
          title: 'توزيع السوق',
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: pieData,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pieData.map((section) {
                    final label = section.title.split('\n').first;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: section.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              color: context.cs.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Line Chart: نمو متوقع (6 أشهر) ─────────────────────────────────
        _buildChartCard(
          context,
          title: 'نمو متوقع (6 أشهر)',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 100,
                lineTouchData: LineTouchData(enabled: false),
                clipData: const FlClipData.all(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          color: context.cs.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'ش1',
                          'ش2',
                          'ش3',
                          'ش4',
                          'ش5',
                          'ش6',
                        ];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            months[idx],
                            style: TextStyle(
                              color: context.cs.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.cs.border,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getGrowthSpots(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helpers for competitor stats ─────────────────────────────────────────

  Widget _buildStatChip(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.cs.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: context.cs.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  // ─── Recommendation Card ─────────────────────────────────────────────────

  Widget _buildRecommendationCard(BuildContext context, List<String> recs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // عنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'توصيات مخصصة لمشروعك',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.cs.primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // التوصيات
          ...recs.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      e.value,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.cs.textPrimary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── AI Badge ─────────────────────────────────────────────────────────────

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF00BCD4), size: 16),
          const SizedBox(width: 8),
          Text(
            'سيتم ربط هذا التحليل بنموذج الذكاء الاصطناعي قريباً',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF0097A7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
