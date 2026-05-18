import 'package:flutter/material.dart';
import '../../../core/models/project_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';

/// شاشة تفاصيل المشروع
class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  Color _scoreColor(double s) {
    if (s >= 80) return AppColors.success;
    if (s >= 60) return AppColors.warning;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final score = project.score ?? 0.0;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                    ),
                    const Spacer(),
                    Text(
                      'تفاصيل المشروع',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: context.cs.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ─── بطاقة اسم المشروع والتقييم ──────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.cs.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: context.cs.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              project.businessEmoji ?? '🏪',
                              style: const TextStyle(fontSize: 56),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              project.projectName,
                              style: AppTextStyles.headingLarge.copyWith(
                                color: context.cs.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              project.businessType,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.cs.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // دائرة التقييم
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _scoreColor(score),
                                  width: 5,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${score.toInt()}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _scoreColor(score),
                                      ),
                                    ),
                                    Text(
                                      'تقييم',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: context.cs.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ─── تفاصيل المشروع ───────────────────────────────
                      _buildSection(
                        context: context,
                        title: 'معلومات المشروع',
                        icon: Icons.info_outline,
                        items: [
                          _detail(context, 'الفئة المستهدفة', project.targetAudience),
                          _detail(context, 'المساحة', project.area),
                          _detail(context, 'الميزانية', project.budget),
                          _detail(context, 'المعالم القريبة', project.nearbyLandmarks),
                          if (project.cafeType != null)
                            _detail(context, 'نوع المقهى', project.cafeType!),
                          if (project.restaurantType != null)
                            _detail(context, 'نوع المطعم', project.restaurantType!),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ─── الخصائص ──────────────────────────────────────
                      _buildSection(
                        context: context,
                        title: 'الخصائص',
                        icon: Icons.check_circle_outline,
                        items: [
                          _toggle(context, '24 ساعة', project.is24Hours),
                          _toggle(context, 'جلوس داخلي', project.hasInternalSeating),
                          _toggle(context, 'خدمة سيارة', project.hasCarService),
                          _toggle(context, 'طاولات خارجية', project.hasExternalTables),
                          _detail(context, 'الاعتماد على التوصيل', project.dependsOnDelivery),
                          if (project.hasParking != null)
                            _toggle(context, 'موقف سيارات', project.hasParking!),
                        ],
                      ),
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

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cs.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.headingSmall.copyWith(
                  color: context.cs.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...items,
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.cs.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.cs.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(BuildContext context, String label, bool? value) {
    final active = value == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.cancel_outlined,
            color: active ? AppColors.success : AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? context.cs.textPrimary : context.cs.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
