import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji/Icon
          Text(emoji, style: const TextStyle(fontSize: 120)),

          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: context.cs.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
