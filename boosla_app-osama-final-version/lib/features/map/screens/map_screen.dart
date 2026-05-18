import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/models/heatmap_model.dart';
import '../../../core/services/heatmap_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final HeatmapService _heatmapService = HeatmapService.instance;

  static const LatLng _riyadh = LatLng(24.7136, 46.6753);

  String? _selectedCategoryId; // null = لم يُختر بعد
  double _zoom = 11.5;

  HeatmapCategory? get _selectedCategory =>
      _selectedCategoryId != null
          ? _heatmapService.getCategoryById(_selectedCategoryId!)
          : null;

  // ─── بناء دوائر الـ Heatmap عبر الـ Service ──────────────────────────────
  List<CircleMarker> _buildHeatCircles() {
    if (_selectedCategory == null) return [];
    return _heatmapService.buildCircles(_selectedCategory!);
  }

  void _zoomIn() {
    _zoom = (_zoom + 1).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, _zoom);
    setState(() {});
  }

  void _zoomOut() {
    _zoom = (_zoom - 1).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, _zoom);
    setState(() {});
  }

  void _goToRiyadh() {
    _mapController.move(_riyadh, 11.5);
    setState(() => _zoom = 11.5);
  }

  @override
  Widget build(BuildContext context) {
    final cat = _selectedCategory;

    return Scaffold(
      body: Stack(
        children: [
          // ─── الخريطة ─────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _riyadh,
              initialZoom: _zoom,
              onPositionChanged: (pos, _) => _zoom = pos.zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.boosla.app',
              ),
              CircleLayer(circles: _buildHeatCircles()),
            ],
          ),

          // ─── Header ──────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildHeader(cat),
            ),
          ),

          // ─── أزرار التحكم ─────────────────────────────────────────────────
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                _mapBtn(Icons.add, _zoomIn),
                const SizedBox(height: 8),
                _mapBtn(Icons.remove, _zoomOut),
                const SizedBox(height: 8),
                _mapBtn(Icons.my_location, _goToRiyadh),
              ],
            ),
          ),

          // ─── Bottom: اختيار الفئة أو Legend ──────────────────────────────
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: cat == null
                ? _buildCategorySelector()
                : _buildActiveLegend(cat),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(HeatmapCategory? cat) {
    return Builder(
      builder: (context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          if (cat != null)
            GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = null),
              child: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.primary),
            )
          else
            const Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cat != null ? '${cat.emoji}  ${cat.label}' : '🗺️  صفحة الخريطة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.cs.primaryText,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ─── اختيار الفئة ─────────────────────────────────────────────────────────
  Widget _buildCategorySelector() {
    final cats = HeatmapService.categories;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اختر نوع نشاطك',
            style: AppTextStyles.headingSmall.copyWith(
              color: context.cs.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: cats.map((cat) {
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryId = cat.id),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: cat.color.withOpacity(0.4), width: 1.5),
                      ),
                      child: Center(
                        child: Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.label.replaceAll('مشاريع ', ''),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.cs.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Legend بعد الاختيار ──────────────────────────────────────────────────
  Widget _buildActiveLegend(HeatmapCategory cat) {
    final hotspots = _heatmapService.getTopHotspots(cat.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ─── Header الـ Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedCategoryId = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('تغيير', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    cat.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ─── شريط التدرج
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    cat.color.withOpacity(0.12),
                    cat.color.withOpacity(0.40),
                    cat.color.withOpacity(0.70),
                    cat.color,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مرتفع جداً', style: AppTextStyles.caption.copyWith(
                  color: context.cs.textSecondary, fontWeight: FontWeight.bold)),
              Text('منخفض', style: AppTextStyles.caption.copyWith(
                  color: context.cs.textSecondary)),
            ],
          ),

          // ─── أعلى 3 مناطق
          if (hotspots.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'أعلى المناطق كثافة',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.cs.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 6),
            ...hotspots.asMap().entries.map((e) {
              final rank = e.key + 1;
              final pt   = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // شريط الكثافة
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pt.intensity,
                          backgroundColor: cat.color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(cat.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          pt.label ?? '—',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: context.cs.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: cat.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ─── زر تحكم ─────────────────────────────────────────────────────────────
  Widget _mapBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.cs.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}
