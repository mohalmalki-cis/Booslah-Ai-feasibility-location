import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_color_scheme.dart';

/// ويدجت حالة الخطأ — الأسبوع الثامن
/// يعرض رسالة خطأ مع زر إعادة المحاولة

class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.message = 'حدث خطأ غير متوقع',
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الخطأ
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.error, size: 48),
            ),

            const SizedBox(height: 20),

            // رسالة الخطأ
            Text(
              message,
              style: AppTextStyles.headingSmall.copyWith(
                color: context.cs.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.cs.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ويدجت حالة فارغة (لا توجد مشاريع مثلاً)
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;
  final String emoji;

  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onAction,
    this.emoji = '📭',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الإيموجي الكبير
            Text(emoji, style: const TextStyle(fontSize: 64)),

            const SizedBox(height: 20),

            // العنوان
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                color: context.cs.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.cs.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
