import 'package:flutter/material.dart';
import '../../../core/services/project_advice_service.dart';
import '../../../core/theme/app_text_styles.dart';

class AiAdviceWidget extends StatefulWidget {
  final Map<String, dynamic> projectData;
  const AiAdviceWidget({super.key, required this.projectData});

  @override
  State<AiAdviceWidget> createState() => _AiAdviceWidgetState();
}

class _AiAdviceWidgetState extends State<AiAdviceWidget> {
  static const _navy = Color(0xFF1B3C5A);

  List<ProjectAdvice>? _advice;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    print('=== WIDGET PROJECT DATA ===');
    print(widget.projectData.toString());
    try {
      final result =
          await ProjectAdviceService().getAdvice(widget.projectData);
      if (mounted) setState(() => _advice = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildSkeleton();
    if (_error != null) return _buildError();
    return _buildCard();
  }

  // ─── Skeleton ─────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _shimmer(width: 200, height: 18),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _shimmer(width: double.infinity, height: 52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'تعذّر تحميل التوصيات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? '',
            style: AppTextStyles.caption.copyWith(color: Colors.red.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Success Card ─────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'توصيات الذكاء الاصطناعي',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: _navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Divider(height: 1),
            ),

            // ── Sub-header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'توصيات مخصصة لمشروعك',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Advice Items ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _advice!.map((item) => _buildAdviceItem(item)).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // ── Bottom Banner ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم ربط هذا التحليل بنموذج الذكاء الاصطناعي قريباً',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceItem(ProjectAdvice item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2, left: 10),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.number}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          // Advice text
          Expanded(
            child: Text(
              item.text,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF1F2937),
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
