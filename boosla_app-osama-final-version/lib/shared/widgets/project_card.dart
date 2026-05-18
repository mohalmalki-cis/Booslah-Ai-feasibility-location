import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String businessType;
  final String location;
  final double score;
  final String date;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.businessType,
    required this.location,
    required this.score,
    required this.date,
    required this.onTap,
  });

  String _getBusinessEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'مقهى':
      case 'cafe':
        return '☕';
      case 'مطعم':
      case 'restaurant':
        return '🍔';
      case 'بقالة':
      case 'grocery':
        return '🛒';
      default:
        return '🏪';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Business Type Emoji
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.cs.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getBusinessEmoji(businessType),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Project Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Name
                    Text(
                      projectName,
                      style: AppTextStyles.headingSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Business Type
                    Text(
                      businessType,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.cs.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 4),

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

                    const SizedBox(height: 8),

                    // Date
                    Text(date, style: AppTextStyles.caption),
                  ],
                ),
              ),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'نقطة',
                      style: AppTextStyles.caption.copyWith(
                        color: _getScoreColor(score),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
