import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

/// ودجت الموقع المتوقع من الذكاء الاصطناعي
/// ─────────────────────────────────────────
/// [predictedLocation] — الإحداثيات القادمة من الـ AI
///   • null  → يعرض placeholder "في انتظار التحليل"
///   • LatLng → يعرض الخريطة مع بين على الموقع
///
/// لاحقاً عند ربط الـ AI:
///   PredictedLocationWidget(predictedLocation: LatLng(lat, lng))

class PredictedLocationWidget extends StatelessWidget {
  final LatLng? predictedLocation;
  final String? neighborhoodName; // اسم الحي — اختياري

  const PredictedLocationWidget({
    super.key,
    this.predictedLocation,
    this.neighborhoodName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ─── العنوان ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Badge الذكاء الاصطناعي
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF00BCD4).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 12, color: Color(0xFF0097A7)),
                      const SizedBox(width: 4),
                      Text(
                        'ذكاء اصطناعي',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF0097A7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'الموقع المقترح',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.cs.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // ─── الخريطة أو الـ Placeholder ───────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: predictedLocation == null
                ? _buildPlaceholder(context)
                : _buildMap(context, predictedLocation!),
          ),
        ],
      ),
    );
  }

  // ─── Placeholder — قبل ربط الـ AI ────────────────────────────────────────
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1a1a1a) : const Color(0xFFF8FAFC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_searching,
              size: 36,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'في انتظار تحليل الذكاء الاصطناعي',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.cs.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سيظهر الموقع المقترح هنا بعد الربط',
            style: AppTextStyles.caption.copyWith(
              color: context.cs.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ─── الخريطة الفعلية — بعد ربط الـ AI ───────────────────────────────────
  Widget _buildMap(BuildContext context, LatLng location) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: location,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none, // الخريطة ثابتة (للعرض فقط)
              ),
            ),
            children: [
              // طبقة الخريطة
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.boosla.app',
              ),

              // بين الموقع المتوقع
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: 48,
                    height: 48,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        // ذيل البين
                        CustomPaint(
                          size: const Size(10, 6),
                          painter: _MarkerTailPainter(AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // اسم الحي (لو موجود)
          if (neighborhoodName != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      neighborhoodName!,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.cs.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── رسم ذيل البين ────────────────────────────────────────────────────────
class _MarkerTailPainter extends CustomPainter {
  final Color color;
  const _MarkerTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
