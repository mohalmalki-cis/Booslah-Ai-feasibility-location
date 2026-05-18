import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/project_details.dart';
import 'analysis_methods_screen.dart';

class CafeDetailsScreen extends StatefulWidget {
  final String businessType;
  final String businessEmoji;
  final String businessId;

  const CafeDetailsScreen({
    super.key,
    required this.businessType,
    required this.businessEmoji,
    required this.businessId,
  });

  @override
  State<CafeDetailsScreen> createState() => _CafeDetailsScreenState();
}

class _CafeDetailsScreenState extends State<CafeDetailsScreen> {
  final TextEditingController _projectNameController = TextEditingController();

  // Toggles
  bool _is24Hours = false;
  bool _hasInternalSeating = true;
  bool _hasCarService = false;
  bool _hasExternalTables = false;

  // Dropdowns — القيمة المخزنة هي الإنجليزية (تتوافق مع الـ dataset)
  // _cafeType: محذوف — غير موجود في الـ dataset (cafes_with_scores.csv)
  String? _targetAudience;
  String? _area;
  String? _budget;
  List<String> _nearbyLandmarks = [];
  String? _openingHours;
  String? _dependsOnDelivery; // Low / Medium / High
  int? _shopAge; // اختياري — يحسّن دقة الموديل

  // Map<قيمة_تُخزن, عرض_عربي>
  final Map<String, String> _targetAudienceOptions = {
    'Employees': 'موظفون',
    'Students': 'طلاب',
    'Mixed': 'متنوع',
    'Families': 'عائلات',
    'Youth': 'شباب',
  };

  final Map<String, String> _areaOptions = {
    'Small': 'صغير  (أقل من 50م²)',
    'Medium': 'متوسط (50 - 150م²)',
    'Large': 'كبير  (أكثر من 150م²)',
  };

  final Map<String, String> _budgetOptions = {
    'Low': 'منخفضة  (أقل من 200 ألف)',
    'Medium': 'متوسطة  (200 - 500 ألف)',
    'High': 'مرتفعة  (أكثر من 500 ألف)',
  };

  final Map<String, String> _landmarkOptions = {
    'Unspecified': 'غير محدد',
    'School': 'مدرسة / جامعة',
    'Mall': 'مركز تجاري',
    'Hospital': 'مستشفى',
    'Mosque': 'مسجد',
    'Main Road': 'شارع رئيسي',
    'Inside Neighborhood': 'داخل حي سكني',
  };

  final Map<String, String> _openingHoursOptions = {
    'Morning': 'صباحي فقط',
    'Evening': 'مسائي فقط',
    'Both': 'صباحي ومسائي',
  };

  // depends_on_delivery_orders — متوافق مع الـ dataset
  final Map<String, String> _deliveryOptions = {
    'Low': 'منخفض  (أقل من 20٪)',
    'Medium': 'متوسط  (20٪ - 50٪)',
    'High': 'مرتفع  (أكثر من 50٪)',
  };

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // Validation
    if (_projectNameController.text.trim().isEmpty) {
      _showError('الرجاء إدخال اسم المشروع');
      return;
    }
    if (_targetAudience == null) {
      _showError('الرجاء اختيار الفئة المستهدفة');
      return;
    }
    if (_area == null) {
      _showError('الرجاء اختيار مساحة المحل');
      return;
    }
    if (_budget == null) {
      _showError('الرجاء اختيار الميزانية');
      return;
    }
    if (_nearbyLandmarks.isEmpty) {
      _showError('الرجاء اختيار المعالم القريبة');
      return;
    }
    if (_openingHours == null) {
      _showError('الرجاء اختيار أوقات العمل');
      return;
    }
    if (_dependsOnDelivery == null) {
      _showError('الرجاء اختيار مستوى الاعتماد على التوصيل');
      return;
    }

    // Create project details
    final projectDetails = ProjectDetails(
      businessId: widget.businessId,
      businessType: widget.businessType,
      businessEmoji: widget.businessEmoji,
      projectName: _projectNameController.text.trim(),
      is24Hours: _is24Hours,
      hasInternalSeating: _hasInternalSeating,
      hasCarService: _hasCarService,
      hasExternalTables: _hasExternalTables,
      dependsOnDelivery: _dependsOnDelivery!,
      targetAudience: _targetAudience!,
      area: _area!,
      budget: _budget!,
      nearbyLandmarks: _nearbyLandmarks.join(', '),
      openingHours: _openingHours,
      shopAge: _shopAge,
      // cafeType: null — غير موجود في dataset الذكاء الاصطناعي
    );

    // Navigate to analysis methods with project details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnalysisMethodsScreen(projectDetails: projectDetails),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                    ),
                    const Spacer(),
                    Text(
                      'حدد خصائص المشروع',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Selected Business Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.cs.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.businessEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'نوع المشروع: ${widget.businessType}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Project Name
                      _buildTextField(
                        controller: _projectNameController,
                        label: 'اسم المشروع',
                        hint: 'مثال: مقهى النخيل',
                      ),

                      const SizedBox(height: 16),

                      // Toggles
                      _buildToggleCard(
                        title: 'على مدار 24 ساعة؟',
                        value: _is24Hours,
                        onChanged: (value) {
                          setState(() {
                            _is24Hours = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildToggleCard(
                        title: 'الجلوس بالداخل',
                        value: _hasInternalSeating,
                        onChanged: (value) {
                          setState(() {
                            _hasInternalSeating = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildToggleCard(
                        title: 'خدمة السيارات',
                        value: _hasCarService,
                        onChanged: (value) {
                          setState(() {
                            _hasCarService = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildToggleCard(
                        title: 'طاولات خارجية',
                        value: _hasExternalTables,
                        onChanged: (value) {
                          setState(() {
                            _hasExternalTables = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Target Audience
                      _buildMapDropdown(
                        label: 'الفئة المستهدفة',
                        value: _targetAudience,
                        options: _targetAudienceOptions,
                        onChanged: (v) => setState(() => _targetAudience = v),
                      ),

                      const SizedBox(height: 16),

                      // Opening Hours
                      _buildMapDropdown(
                        label: 'أوقات العمل',
                        value: _openingHours,
                        options: _openingHoursOptions,
                        onChanged: (v) => setState(() => _openingHours = v),
                      ),

                      const SizedBox(height: 16),

                      // Area
                      _buildMapDropdown(
                        label: 'مساحة المحل',
                        value: _area,
                        options: _areaOptions,
                        onChanged: (v) => setState(() => _area = v),
                      ),

                      const SizedBox(height: 16),

                      // Budget
                      _buildMapDropdown(
                        label: 'الميزانية',
                        value: _budget,
                        options: _budgetOptions,
                        onChanged: (v) => setState(() => _budget = v),
                      ),

                      const SizedBox(height: 16),

                      // Nearby Landmarks
                      _buildLandmarkMultiSelect(context),

                      const SizedBox(height: 16),

                      // Delivery Dependency
                      _buildMapDropdown(
                        label: 'الاعتماد على التوصيل',
                        value: _dependsOnDelivery,
                        options: _deliveryOptions,
                        onChanged: (v) =>
                            setState(() => _dependsOnDelivery = v),
                      ),

                      const SizedBox(height: 16),

                      // Shop Age (اختياري)
                      _buildNumberField(
                        label: 'عمر المشروع (سنوات) — اختياري',
                        hint: 'مثال: 3',
                        value: _shopAge,
                        onChanged: (v) => setState(() => _shopAge = v),
                      ),

                      const SizedBox(height: 32),

                      // Continue Button
                      CustomButton(
                        text: 'التالي',
                        onPressed: _onContinue,
                        icon: Icons.arrow_forward,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: context.cs.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown يعرض عربي ويخزن إنجليزي (للتوافق مع الـ dataset)
  Widget _buildMapDropdown({
    required String label,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            hint: Text(
              'اختر',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.cs.textLight,
              ),
              textAlign: TextAlign.right,
            ),
            items: options.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key, // يُخزن: English
                alignment: Alignment.centerRight,
                child: Text(
                  e.value, // يُعرض: Arabic
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // حقل رقمي اختياري (shop_age)
  Widget _buildNumberField({
    required String label,
    required String hint,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: context.cs.textLight,
              ),
            ),
            onChanged: (text) {
              final parsed = int.tryParse(text.trim());
              onChanged(parsed);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarkMultiSelect(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: Text(
            'المعالم القريبة',
            style: AppTextStyles.label.copyWith(color: context.cs.textSecondary),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cs.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cs.border),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: _landmarkOptions.entries.map((entry) {
              final isSelected = _nearbyLandmarks.contains(entry.key);
              return FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (entry.key == 'Unspecified') {
                      _nearbyLandmarks = selected ? ['Unspecified'] : [];
                    } else {
                      _nearbyLandmarks.remove('Unspecified');
                      if (selected) {
                        _nearbyLandmarks.add(entry.key);
                      } else {
                        _nearbyLandmarks.remove(entry.key);
                      }
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : context.cs.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: context.cs.cardAlt,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : context.cs.border,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: context.cs.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
