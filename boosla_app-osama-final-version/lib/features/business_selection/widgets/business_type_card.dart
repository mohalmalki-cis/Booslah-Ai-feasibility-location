import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

class BusinessTypeCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isAvailable;

  const BusinessTypeCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.description,
    required this.color,
    required this.onTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: context.cs.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.cs.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: context.cs.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji with colored background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Text(
                name,
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 4),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: context.cs.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // "قريباً" text
              if (!isAvailable) ...[
                const SizedBox(height: 4),
                Text(
                  '(قريباً)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
