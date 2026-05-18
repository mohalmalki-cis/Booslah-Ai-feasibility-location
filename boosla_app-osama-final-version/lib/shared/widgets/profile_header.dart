import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const ProfileHeader({super.key, required this.name, this.imageUrl});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 18) return 'مساء الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.secondary,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 30, color: AppColors.primary)
                : null,
          ),

          const SizedBox(width: 16),

          // Name & Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.cs.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Notification Icon
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
