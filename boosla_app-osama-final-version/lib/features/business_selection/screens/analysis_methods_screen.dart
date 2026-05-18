import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/project_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../dashboard/screens/analysis_result_screen.dart';
import '../models/project_details.dart';

class AnalysisMethodsScreen extends StatelessWidget {
  final ProjectDetails projectDetails;

  const AnalysisMethodsScreen({super.key, required this.projectDetails});

  String _typeKey(String id) {
    final l = id.toLowerCase();
    if (l.contains('cafe') || l.contains('كافيه') || l.contains('قهوة') ||
        l.contains('مقهى')) {
      return 'cafe';
    }
    if (l.contains('rest') || l.contains('مطعم')) return 'restaurant';
    if (l.contains('groc') || l.contains('بقال') || l.contains('سوبر')) {
      return 'grocery';
    }
    return 'cafe';
  }

  void _onMethodSelected(BuildContext context, String methodId) async {
    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();
    final uid = authProvider.user?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ─── ١) استدعاء الذكاء الاصطناعي ──────────────────────────────────
    Map<String, dynamic> aiFields = {};
    try {
      aiFields = await AiService.instance.predictForOldScreen({
        'business_type': _typeKey(projectDetails.businessId),
        'budget': projectDetails.budget,
        'area': projectDetails.area,
        'target_audience': projectDetails.targetAudience,
        'nearby_landmarks': projectDetails.nearbyLandmarks,
        'depends_on_delivery': projectDetails.dependsOnDelivery,
        'is_24_hours': projectDetails.is24Hours,
        'has_internal_seating': projectDetails.hasInternalSeating,
        'has_car_service': projectDetails.hasCarService,
        'has_external_tables': projectDetails.hasExternalTables,
        if (projectDetails.shopAge != null) 'shop_age': projectDetails.shopAge,
        if (projectDetails.restaurantType != null)
          'restaurant_type': projectDetails.restaurantType,
        if (projectDetails.openingHours != null)
          'opening_hours': projectDetails.openingHours,
      });
    } catch (e) {
      // إذا فشل الـ AI لأي سبب نكمل بدون النتيجة (الشاشة القديمة عندها fallback)
      aiFields = {};
    }

    // ─── ٢) حفظ المشروع في Firestore (مع نتائج الـ AI) ─────────────────
    final data = {...projectDetails.toJson(), ...aiFields};
    final saved = await projectProvider.saveProject(uid: uid, projectData: data);

    if (!context.mounted) return;

    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ المشروع بنجاح ✓'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // ─── الانتقال لشاشة النتيجة (التصميم الأصلي مع بيانات الـ AI) ──
      if (methodId == 'single_location' && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisResultScreen(project: data),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(projectProvider.errorMessage ?? 'فشل حفظ المشروع، تحقق من الاتصال'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                    ),
                    const Spacer(),
                    Text(
                      'اختر طريقة التحليل',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Project Summary Badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cs.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          projectDetails.businessEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projectDetails.projectName,
                              style: AppTextStyles.headingSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              projectDetails.businessType,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.cs.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Analysis Methods List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildMethodCard(
                      context: context,
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'تحليل موقع واحد',
                      description: 'احصل على تحليل مفصل لموقع محدد',
                      features: [
                        'تقييم شامل للموقع',
                        'تحليل المنافسين القريبين',
                        'دراسة الحركة والكثافة',
                      ],
                      methodId: 'single_location',
                    ),

                    const SizedBox(height: 16),

                    _buildMethodCard(
                      context: context,
                      icon: Icons.compare_arrows,
                      iconColor: const Color(0xFF2196F3),
                      title: 'مقارنة مواقع',
                      description: 'قارن بين عدة مواقع لاختيار الأفضل',
                      features: [
                        'مقارنة حتى 5 مواقع',
                        'جدول مقارنة تفصيلي',
                        'توصيات مبنية على البيانات',
                      ],
                      methodId: 'compare_locations',
                    ),

                    const SizedBox(height: 16),

                    _buildMethodCard(
                      context: context,
                      icon: Icons.explore,
                      iconColor: const Color(0xFFFF9800),
                      title: 'استكشاف المنطقة',
                      description: 'اكتشف أفضل المواقع في منطقة معينة',
                      features: [
                        'خريطة حرارية للفرص',
                        'اقتراحات ذكية للمواقع',
                        'تحليل شامل للمنطقة',
                      ],
                      methodId: 'explore_area',
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // التحليل
        onTap: (index) {
          if (index == 1) {
            // الرئيسية - ارجع للصفحة الرئيسية
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          // باقي التابات TODO
        },
      ),
    );
  }

  Widget _buildMethodCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> features,
    required String methodId,
  }) {
    return GestureDetector(
      onTap: () => _onMethodSelected(context, methodId),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cs.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.cs.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Features
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.cs.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
