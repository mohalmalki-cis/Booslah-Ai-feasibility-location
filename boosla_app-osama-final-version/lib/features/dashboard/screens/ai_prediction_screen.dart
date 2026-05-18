// ═══════════════════════════════════════════════════════════════════════
// AI Prediction Screen — يستدعي AiService ويعرض أفضل 3 مناطق
// يستقبل ProjectDetails من شاشة الـ analysis_methods_screen
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../business_selection/models/project_details.dart';

class AiPredictionScreen extends StatefulWidget {
  final ProjectDetails projectDetails;

  const AiPredictionScreen({super.key, required this.projectDetails});

  @override
  State<AiPredictionScreen> createState() => _AiPredictionScreenState();
}

class _AiPredictionScreenState extends State<AiPredictionScreen> {
  PredictionResult? _result;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  // ─── تحويل ProjectDetails → Map متوافق مع AiService ───────────────
  Map<String, dynamic> _buildAiInput() {
    final p = widget.projectDetails;
    return {
      'business_type': _businessTypeKey(p.businessId),
      'budget': p.budget,
      'area': p.area,
      'target_audience': p.targetAudience,
      'nearby_landmarks': p.nearbyLandmarks,
      'depends_on_delivery': p.dependsOnDelivery,
      'is_24_hours': p.is24Hours,
      'has_internal_seating': p.hasInternalSeating,
      'has_car_service': p.hasCarService,
      'has_external_tables': p.hasExternalTables,
      if (p.shopAge != null) 'shop_age': p.shopAge,
      if (p.restaurantType != null) 'restaurant_type': p.restaurantType,
      if (p.openingHours != null) 'opening_hours': p.openingHours,
    };
  }

  String _businessTypeKey(String id) {
    final l = id.toLowerCase();
    if (l.contains('cafe') || l.contains('كافيه') || l.contains('قهوة')) {
      return 'cafe';
    }
    if (l.contains('rest') || l.contains('مطعم')) return 'restaurant';
    if (l.contains('groc') || l.contains('بقال') || l.contains('سوبر')) {
      return 'grocery';
    }
    return 'cafe';
  }

  Future<void> _runPrediction() async {
    try {
      final input = _buildAiInput();
      final result = await AiService.instance.predictLocation(input);
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.primary,
          ),
          const Spacer(),
          Text(
            'نتيجة التحليل بالذكاء الاصطناعي',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'جاري تحليل أفضل المواقع...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.cs.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 56),
              const SizedBox(height: 12),
              Text(
                'تعذّر تشغيل النموذج',
                style: AppTextStyles.headingSmall.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.cs.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _runPrediction();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final r = _result!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // ── الكرت الرئيسي: الموقع الأفضل
        _buildHeroCard(context, r),

        const SizedBox(height: 18),

        // ── أفضل 3 مناطق
        Text(
          'أفضل 3 مناطق مقترحة:',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),

        ...r.topZones.map((zone) => _buildZoneCard(context, zone)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, PredictionResult r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0a3d62), Color(0xFF1e5f8e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 32),
          const SizedBox(height: 8),
          Text(
            'الموقع الأفضل لمشروعك',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            r.predictedLocation,
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (r.predictedZone != null) ...[
            const SizedBox(height: 4),
            Text(
              'ضمن منطقة: ${r.predictedZone}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                'نسبة الثقة: ${(r.confidence * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, ZonePrediction zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 16,
                child: Text(
                  '${zone.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  zone.zone,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(zone.score * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (zone.bestDistricts.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'الأحياء الأنسب داخل هذه المنطقة:',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.cs.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: zone.bestDistricts
                  .map((d) => Chip(
                        label: Text(d.district),
                        backgroundColor: context.cs.scaffold,
                        side: BorderSide(color: AppColors.border),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
