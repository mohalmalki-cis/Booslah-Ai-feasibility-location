import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/project_provider.dart';
import '../../../core/models/comparison_result.dart';
import '../../../core/services/comparison_service.dart';
import '../../../core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/widgets/score_ring_widget.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  // المشاريع تأتي مباشرة من ProjectProvider (تتحدث تلقائياً)
  Map<String, dynamic>? _projectA;
  Map<String, dynamic>? _projectB;
  bool _showComparison = false;

  // ألوان المشروعين
  static const Color _colorA = Color(0xFF112F4E); // primary
  static const Color _colorB = Color(0xFF0097A7); // teal

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid == null) return;
      await _migrateLocalProjects(uid);
      final provider = context.read<ProjectProvider>();
      if (provider.projects.isEmpty) {
        await provider.loadProjects(uid);
      }
    });
  }

  /// ينقل مشاريع LocalStorage إلى Firestore إذا لم تُرحَّل بعد
  Future<void> _migrateLocalProjects(String uid) async {
    const migratedKey = 'local_projects_migrated';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(migratedKey) == true) return;

    final localProjects = await LocalStorage.getAllProjects();
    if (localProjects.isEmpty) {
      await prefs.setBool(migratedKey, true);
      return;
    }

    final projectProvider = context.read<ProjectProvider>();
    for (final data in localProjects) {
      await projectProvider.saveProject(uid: uid, projectData: data);
    }
    await prefs.setBool(migratedKey, true);
  }

  final _service = ComparisonService.instance;

  void _selectProject(Map<String, dynamic> project) {
    if (_projectA == null) {
      setState(() => _projectA = project);
    } else if (_projectB == null && project['id'] != _projectA!['id']) {
      setState(() => _projectB = project);
    } else if (project['id'] == _projectA!['id']) {
      setState(() => _projectA = null);
    } else if (_projectB != null && project['id'] == _projectB!['id']) {
      setState(() => _projectB = null);
    }
  }

  bool _isSelected(Map<String, dynamic> p) =>
      (_projectA != null && _projectA!['id'] == p['id']) ||
      (_projectB != null && _projectB!['id'] == p['id']);

  int _selectionIndex(Map<String, dynamic> p) {
    if (_projectA != null && _projectA!['id'] == p['id']) return 1;
    if (_projectB != null && _projectB!['id'] == p['id']) return 2;
    return 0;
  }

  String _formatDate(String? d) {
    if (d == null) return '—';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
    } catch (_) {
      return '—';
    }
  }

  // مواقع تقريبية لأحياء الرياض للـ Mini Map
  // نقرأ من الحقول المحفوظة من AI أولاً (ai_latitude, ai_longitude)
  // ولو ما كانت موجودة نرجع لـ Fallback من القائمة الافتراضية
  LatLng _projectLocation(int idx, [Map<String, dynamic>? project]) {
    if (project != null) {
      final lat = project['ai_latitude'];
      final lng = project['ai_longitude'];
      if (lat is num && lng is num) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
    }
    const locations = [
      LatLng(24.7136, 46.6753),
      LatLng(24.7400, 46.7100),
      LatLng(24.6877, 46.7219),
      LatLng(24.8200, 46.6350),
      LatLng(24.5900, 46.7100),
      LatLng(24.7500, 46.8300),
    ];
    return locations[idx % locations.length];
  }

  @override
  Widget build(BuildContext context) {
    // ← watch يعيد بناء الشاشة تلقائياً عند إضافة/حذف مشروع
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects.map((p) => p.toMap()).toList();
    final isLoading = projectProvider.isLoading;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Text(
                      '⚖️ المقارنة',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: context.cs.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // ─── Content ─────────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : projects.isEmpty
                    ? _buildEmptyState()
                    : _showComparison
                    ? _buildComparisonView(projects)
                    : _buildSelectionView(projects),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Empty State
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.balance_outlined, size: 80, color: AppColors.textLight),
        const SizedBox(height: 16),
        Text(
          'لا توجد مشاريع للمقارنة',
          style: AppTextStyles.headingMedium.copyWith(
            color: context.cs.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أنشئ مشروعين على الأقل من الصفحة الرئيسية',
          style: AppTextStyles.bodyMedium.copyWith(color: context.cs.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // Selection View
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildSelectionView(List<Map<String, dynamic>> projects) {
    final canCompare = _projectA != null && _projectB != null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.cs.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'اختر مشروعين لمقارنتهما',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildSelectionBadge(_projectB, _colorB),
              const SizedBox(width: 10),
              _buildSelectionBadge(_projectA, _colorA),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: projects.length,
            itemBuilder: (_, i) => _buildSelectableCard(projects[i]),
          ),
        ),
        if (canCompare)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _showComparison = true),
                icon: const Icon(Icons.compare_arrows, color: Colors.white),
                label: Text(
                  'قارن الآن',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionBadge(Map<String, dynamic>? project, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: project != null
              ? color.withOpacity(0.08)
              : context.cs.borderLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: project != null ? color : context.cs.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                project != null
                    ? (project['projectName'] ?? 'مشروع')
                    : 'لم يُختر بعد',
                style: AppTextStyles.bodySmall.copyWith(
                  color: project != null ? color : context.cs.textLight,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              project != null ? (project['businessEmoji'] ?? '🏪') : '❓',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCard(Map<String, dynamic> project) {
    final selected = _isSelected(project);
    final idx = _selectionIndex(project);
    final isDisabled = !selected && _projectA != null && _projectB != null;
    final badgeColor = idx == 1 ? _colorA : _colorB;

    return GestureDetector(
      onTap: isDisabled ? null : () => _selectProject(project),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? badgeColor.withOpacity(0.07) : context.cs.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? badgeColor : context.cs.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.cs.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            selected
                ? Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.cs.border, width: 1.5),
                    ),
                  ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  project['projectName'] ?? 'مشروع بدون اسم',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  project['businessType'] ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.cs.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              project['businessEmoji'] ?? '🏪',
              style: const TextStyle(fontSize: 36),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Comparison View
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildComparisonView(List<Map<String, dynamic>> projects) {
    // ComparisonService يحسب كل شيء دفعة واحدة
    final result = _service.compare(_projectA!, _projectB!);
    final idxA = projects.indexWhere((p) => p['id'] == _projectA!['id']);
    final idxB = projects.indexWhere((p) => p['id'] == _projectB!['id']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // زر الرجوع
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _showComparison = false),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('تغيير الاختيار'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),

          // ── ١. النتيجة الكلية ────────────────────────────────────────
          _buildSectionTitle('🏆 النتيجة الكلية'),
          const SizedBox(height: 12),
          _buildScoreCards(result.scoreA, result.scoreB, result.winner),

          const SizedBox(height: 24),

          // ── ٢. جدول العوامل التفصيلية ────────────────────────────────
          _buildSectionTitle('📊 جدول المقارنة التفصيلية'),
          const SizedBox(height: 12),
          _buildDetailedTable(result.factorsA, result.factorsB),

          const SizedBox(height: 24),

          // ── ٣. الفروقات الرئيسية ──────────────────────────────────────
          _buildSectionTitle('🔍 الفروقات الرئيسية'),
          const SizedBox(height: 12),
          _buildDifferencesCard(result.differences),

          const SizedBox(height: 24),

          // ── ٤. الخريطة ────────────────────────────────────────────────
          _buildSectionTitle('🗺️ الموقع التقريبي'),
          const SizedBox(height: 12),
          _buildMiniMap(idxA, idxB),

          const SizedBox(height: 24),

          // ── ٥. معلومات المشروعين ──────────────────────────────────────
          _buildSectionTitle('📋 معلومات المشروعين'),
          const SizedBox(height: 12),
          _buildInfoTable(result.tableRows),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      title,
      style: AppTextStyles.headingSmall.copyWith(
        color: context.cs.primaryText,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // ─── ١. Score Cards جنب بجنب ────────────────────────────────────────────

  Widget _buildScoreCards(double scoreA, double scoreB, String winner) {
    return Row(
      children: [
        // Project B
        Expanded(
          child: _buildScoreCard(_projectB!, scoreB, _colorB, winner == 'B'),
        ),
        const SizedBox(width: 12),
        // VS
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Project A
        Expanded(
          child: _buildScoreCard(_projectA!, scoreA, _colorA, winner == 'A'),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    Map<String, dynamic> project,
    double score,
    Color color,
    bool isWinner,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner ? color : AppColors.border,
          width: isWinner ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isWinner)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🥇 الأفضل',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            project['businessEmoji'] ?? '🏪',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            project['projectName'] ?? '—',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Score Ring صغير
          ScoreRingWidget(score: score, size: 110),
        ],
      ),
    );
  }

  // ─── ٢. Detailed Analysis Table ─────────────────────────────────────────

  Widget _buildDetailedTable(
    List<ComparisonFactor> factorsA,
    List<ComparisonFactor> factorsB,
  ) {
    return Container(
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
        children: [
          // رأس الجدول
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _projectB!['projectName'] ?? '—',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _colorB,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Center(
                    child: Text(
                      'العامل',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      _projectA!['projectName'] ?? '—',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _colorA,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // صفوف العوامل
          ...List.generate(factorsA.length, (i) {
            return _buildTableRow(
              label: factorsA[i].label,
              icon: factorsA[i].icon,
              scoreA: factorsA[i].score,
              scoreB: factorsB[i].score,
              isLast: i == factorsA.length - 1,
            );
          }),
        ],
      ),
    );
  }

  // ─── بطاقة الفروقات الرئيسية ────────────────────────────────────────────
  Widget _buildDifferencesCard(List<ComparisonDiff> diffs) {
    return Container(
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
        children: diffs.asMap().entries.map((e) {
          final diff = e.value;
          final isLast = e.key == diffs.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5),
                    ),
            ),
            child: Row(
              children: [
                // قيمة B
                Expanded(
                  child: Text(
                    diff.valueB,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: diff.aIsBetter == false
                          ? AppColors.success
                          : _colorB,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // العامل
                SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      Icon(diff.icon, size: 15, color: AppColors.primary),
                      const SizedBox(height: 2),
                      Text(
                        diff.label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                // قيمة A
                Expanded(
                  child: Text(
                    diff.valueA,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: diff.aIsBetter == true
                          ? AppColors.success
                          : _colorA,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRow({
    required String label,
    required IconData icon,
    required double scoreA,
    required double scoreB,
    required bool isLast,
  }) {
    final aWins = scoreA > scoreB;
    final bWins = scoreB > scoreA;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Score B (يمين)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (bWins)
                      const Icon(
                        Icons.arrow_upward,
                        size: 12,
                        color: AppColors.success,
                      ),
                    Text(
                      '${scoreB.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: bWins
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: scoreB / 100,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      bWins ? _colorB : _colorB.withOpacity(0.4),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          // العامل (وسط)
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          // Score A (يسار)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${scoreA.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: aWins
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (aWins)
                      const Icon(
                        Icons.arrow_upward,
                        size: 12,
                        color: AppColors.success,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: scoreA / 100,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      aWins ? _colorA : _colorA.withOpacity(0.4),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ٣. Mini Map ────────────────────────────────────────────────────────

  Widget _buildMiniMap(int idxA, int idxB) {
    final locA = _projectLocation(idxA < 0 ? 0 : idxA, _projectA);
    final locB = _projectLocation(idxB < 0 ? 1 : idxB, _projectB);
    final center = LatLng(
      (locA.latitude + locB.latitude) / 2,
      (locA.longitude + locB.longitude) / 2,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 10.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Mini map ثابت
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.boosla.app',
                ),
                MarkerLayer(
                  markers: [
                    // Marker A
                    Marker(
                      point: locA,
                      width: 44,
                      height: 44,
                      child: _buildMapMarker(
                        _projectA!['businessEmoji'] ?? '🏪',
                        _colorA,
                      ),
                    ),
                    // Marker B
                    Marker(
                      point: locB,
                      width: 44,
                      height: 44,
                      child: _buildMapMarker(
                        _projectB!['businessEmoji'] ?? '🏪',
                        _colorB,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Legend فوق الخريطة
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.cs.card.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadow, blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMapLegendItem(
                      _colorA,
                      _projectA!['projectName'] ?? '—',
                    ),
                    const SizedBox(height: 4),
                    _buildMapLegendItem(
                      _colorB,
                      _projectB!['projectName'] ?? '—',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarker(String emoji, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
        CustomPaint(size: const Size(10, 6), painter: _TrianglePainter(color)),
      ],
    );
  }

  Widget _buildMapLegendItem(Color color, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: AppTextStyles.caption.copyWith(
            color: context.cs.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 6),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  // ─── ٤. Info Table (بيانات أساسية) ────────────────────────────────────────

  Widget _buildInfoTable(List<ComparisonTableRow> rows) {
    return Container(
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
        children: rows.asMap().entries.map((e) {
          final row = e.value;
          final isLast = e.key == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.valueB,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _colorB,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Column(
                    children: [
                      Icon(row.icon, size: 16, color: AppColors.primary),
                      const SizedBox(height: 2),
                      Text(
                        row.label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    row.valueA,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _colorA,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Triangle Painter للـ Marker ────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
