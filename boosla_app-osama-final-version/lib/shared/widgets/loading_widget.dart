import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_color_scheme.dart';

/// ويدجت التحميل — الأسبوع الثامن
/// ثلاث حالات: دائرة بسيطة، Skeleton shimmer، شريط خطي

// ─── تحميل دائري رئيسي ───────────────────────────────────────────────────
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const AppLoadingWidget({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: color ?? context.cs.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Skeleton Shimmer (لمحاكاة بطاقات التحميل) ───────────────────────────
class SkeletonCard extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 16,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// قائمة Skeleton لشاشة سجل التحليل
class SkeletonProjectList extends StatelessWidget {
  final int count;
  const SkeletonProjectList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
            child: Row(
              children: [
                // زر العمليات
                const SkeletonCard(height: 24, width: 24, borderRadius: 6),
                const SizedBox(width: 12),
                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SkeletonCard(
                        height: 14,
                        width: MediaQuery.of(context).size.width * 0.4,
                        borderRadius: 6,
                      ),
                      const SizedBox(height: 8),
                      SkeletonCard(
                        height: 11,
                        width: MediaQuery.of(context).size.width * 0.3,
                        borderRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // الإيموجي
                const SkeletonCard(height: 44, width: 44, borderRadius: 12),
              ],
            ),
          ),
        );
      }),
    );
  }
}
