import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

/// دائرة النتيجة الكبيرة مع أنيميشن عند الفتح
class ScoreRingWidget extends StatefulWidget {
  final double score;        // 0 – 100
  final double size;
  final String label;

  const ScoreRingWidget({
    super.key,
    required this.score,
    this.size = 200,
    this.label = 'النتيجة الكلية',
  });

  @override
  State<ScoreRingWidget> createState() => _ScoreRingWidgetState();
}

class _ScoreRingWidgetState extends State<ScoreRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _scoreColor(double s) {
    if (s >= 75) return AppColors.success;
    if (s >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(double s) {
    if (s >= 75) return 'ممتاز';
    if (s >= 60) return 'جيد';
    if (s >= 50) return 'متوسط';
    return 'ضعيف';
  }

  @override
  Widget build(BuildContext context) {
    // حماية من قيم غير صالحة (NaN, Infinity, > 100, < 0)
    final safeScore = widget.score.isFinite
        ? widget.score.clamp(0.0, 100.0)
        : 0.0;
    final color = _scoreColor(safeScore);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final animated = safeScore * _anim.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الرسمة
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: animated / 100,
                  color: color,
                  trackColor: context.cs.borderLight,
                  strokeWidth: widget.size * 0.09,
                ),
              ),

              // النص في المنتصف
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animated.toInt().toString(),
                    style: TextStyle(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.cs.textSecondary,
                      fontSize: widget.size * 0.07,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _scoreLabel(widget.score),
                      style: TextStyle(
                        fontSize: widget.size * 0.07,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    const startAngle = -pi / 2;          // يبدأ من الأعلى
    const fullSweep  = 2 * pi;

    // حماية: نضمن أن progress قيمة صحيحة بين 0 و 1
    final p = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track (الخلفية) — دائماً نرسمها
    canvas.drawCircle(center, radius, trackPaint);

    // إذا progress = 0 أو غير صالحة، لا نرسم القوس (يمنع الـ assertion)
    if (p <= 0.0) return;

    // نضمن endAngle > startAngle بفرق ضئيل على الأقل
    final sweep = (fullSweep * p).clamp(0.001, fullSweep);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: [color.withOpacity(0.6), color],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
