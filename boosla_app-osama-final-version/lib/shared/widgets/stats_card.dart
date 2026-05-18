import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 24),
          ),

          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.cs.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
