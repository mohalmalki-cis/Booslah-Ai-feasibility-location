import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../core/animations/fade_slide_widget.dart';
import '../../../core/animations/app_transitions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/project_provider.dart';
import '../../../core/models/project_model.dart';
import '../../dashboard/screens/analysis_result_screen.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ProjectProvider>().loadProjects(uid);
      }
    });
  }

  Future<void> _deleteProject(String projectId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حذف المشروع',
          textAlign: TextAlign.right,
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا المشروع؟',
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid == null) return;

      final success = await context.read<ProjectProvider>().deleteProject(
        uid: uid,
        projectId: projectId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم حذف المشروع بنجاح' : 'فشل حذف المشروع'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openProjectDashboard(ProjectModel project) {
    Navigator.push(
      context,
      FadeScalePageRoute(
        builder: (_) => AnalysisResultScreen(project: project.toMap()),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'تاريخ غير معروف';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'اليوم';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return 'تاريخ غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;
    final isLoading = projectProvider.isLoading;

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
                    const SizedBox(width: 48),
                    Text(
                      'سجل التحليلات',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: context.cs.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    // ── Skeleton Loading ──────────────────────────────────
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SkeletonProjectList(count: 4),
                      )
                    : projects.isEmpty
                    // ── Empty State ───────────────────────────────────────
                    ? const AppEmptyState(
                        emoji: '📊',
                        title: 'لا توجد تحليلات سابقة',
                        subtitle: 'ابدأ مشروعك الأول من الصفحة الرئيسية\nوسيظهر هنا بعد الحفظ',
                      )
                    // ── قائمة المشاريع مع أنيميشن ─────────────────────
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return FadeSlideWidget(
                            delay: Duration(milliseconds: 60 * index),
                            child: _buildProjectCard(project),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header Row
          Row(
            children: [
              // Delete Button
              IconButton(
                onPressed: () => _deleteProject(project.id),
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                iconSize: 22,
              ),

              const Spacer(),

              // Project Info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      project.projectName,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.businessType,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.cs.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Emoji
              Text(
                project.businessEmoji,
                style: const TextStyle(fontSize: 40),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(height: 1, color: AppColors.border),

          const SizedBox(height: 12),

          _buildDetailRow(
            icon: Icons.access_time,
            text: _formatDate(project.createdAt.toIso8601String()),
          ),

          if (project.cafeType != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(icon: Icons.local_cafe, text: project.cafeType!),
          ],

          if (project.restaurantType != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(icon: Icons.restaurant, text: project.restaurantType!),
          ],

          const SizedBox(height: 8),
          _buildDetailRow(icon: Icons.people_outline, text: project.targetAudience),

          const SizedBox(height: 8),
          _buildDetailRow(icon: Icons.square_foot, text: project.area),

          const SizedBox(height: 8),
          _buildDetailRow(icon: Icons.attach_money, text: project.budget),

          const SizedBox(height: 16),

          // View Dashboard Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openProjectDashboard(project),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'عرض الداشبورد',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.cs.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: AppColors.textSecondary),
      ],
    );
  }
}
