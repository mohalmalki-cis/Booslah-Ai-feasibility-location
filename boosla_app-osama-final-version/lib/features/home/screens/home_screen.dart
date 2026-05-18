import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../settings/screens/settings_screen.dart';
import '../../business_selection/screens/business_type_screen.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/project_provider.dart';
import '../../../core/models/project_model.dart';
import 'project_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المشاريع بعد بناء الشجرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ProjectProvider>().loadProjects(uid);
      }
    });
  }

  void _createNewProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessTypeScreen()),
    );
  }

  void _openProject(ProjectModel project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailsScreen(project: project),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;
    final isLoading = projectProvider.isLoading;
    final hasError  = projectProvider.status == ProjectStatus.error;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _openSettings,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: context.cs.secondary,
                        child: const Icon(
                          Icons.person,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      'الصفحة الرئيسية',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: context.cs.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Spacer for balance
                    const SizedBox(width: 50),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // المشاريع السابقة Title
                      Text(
                        'المشاريع السابقة',
                        style: AppTextStyles.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Projects List (Horizontal Scroll)
                      if (isLoading)
                        const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (hasError)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Icon(Icons.cloud_off_outlined,
                                    size: 56, color: AppColors.error),
                                const SizedBox(height: 12),
                                Text(
                                  projectProvider.errorMessage ?? 'تعذّر تحميل المشاريع',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () {
                                    final uid = context
                                        .read<AuthProvider>()
                                        .user
                                        ?.uid;
                                    if (uid != null) {
                                      context
                                          .read<ProjectProvider>()
                                          .refresh();
                                    }
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة المحاولة'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (projects.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.folder_outlined,
                                    size: 64, color: context.cs.textLight),
                                const SizedBox(height: 16),
                                Text('لا توجد مشاريع بعد',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                        color: context.cs.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(right: 0),
                            itemCount: projects.length,
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(left: 12),
                                child: _buildProjectCard(
                                  emoji: project.businessEmoji,
                                  name: project.projectName,
                                  type: project.businessType,
                                  location: project.nearbyLandmarks,
                                  score: project.score ?? 0.0,
                                  onTap: () => _openProject(project),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 24),

                      // إبداء مشروع جديد Button
                      CustomButton(
                        text: 'إبداء مشروع جديد',
                        onPressed: _createNewProject,
                        icon: Icons.add,
                      ),

                      const SizedBox(height: 24),

                      // نصائح للذكاء الاصطناعي Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.cs.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.cs.shadow,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon + Title
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4DD0E1,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline,
                                    color: Color(0xFF00BCD4),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'نصائح للذكاء الاصطناعي',
                                  style: AppTextStyles.headingSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // نصيحة 1
                            _buildTipItem(
                              '1. جرب عدة مواقع لمقارنة النتائج للحصول على أفضل موقع لنشاطك التجاري',
                            ),

                            const SizedBox(height: 12),

                            // نصيحة 2
                            _buildTipItem(
                              '2. استفد من خيار الحرارة والمؤشرات ليساعد بتحديد مدى قوة الموقع والمنطقة',
                            ),

                            const SizedBox(height: 12),

                            // نصيحة 3
                            _buildTipItem(
                              '3. تحقق من التفاصيل المتقدمة للحصول على معلومات أكثر دقة',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // انضم إلى مجتمع بوصلة Button
                      CustomButton(
                        text: 'انضم إلى مجتمع بوصلة الآن',
                        onPressed: () {
                          // TODO: Open community
                        },
                        isOutlined: true,
                      ),

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

  Widget _buildProjectCard({
    required String emoji,
    required String name,
    required String type,
    required String location,
    required double score,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji
            Text(emoji, style: const TextStyle(fontSize: 40)),

            const Spacer(),

            // Project Name
            Text(
              name,
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Type
            Text(
              type,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.cs.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: context.cs.textLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: AppTextStyles.caption.copyWith(
                      color: context.cs.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Score Badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${score.toInt()}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.cs.card,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: AppColors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.cs.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
