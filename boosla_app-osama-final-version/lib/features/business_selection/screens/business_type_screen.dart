import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/models/business_type_model.dart';
import '../../../shared/widgets/background_widget.dart';
import '../widgets/business_type_card.dart';
import 'cafe_details_screen.dart';
import 'restaurant_details_screen.dart';
import 'grocery_details_screen.dart';

class BusinessTypeScreen extends StatefulWidget {
  const BusinessTypeScreen({super.key});

  @override
  State<BusinessTypeScreen> createState() => _BusinessTypeScreenState();
}

class _BusinessTypeScreenState extends State<BusinessTypeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── يستخدم BusinessTypeModel.all بدل القائمة المكررة ────────────────────
  List<BusinessTypeModel> get _filteredBusinessTypes {
    if (_searchQuery.isEmpty) return BusinessTypeModel.all;
    return BusinessTypeModel.all
        .where((t) =>
            t.name.contains(_searchQuery) ||
            t.description.contains(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBusinessTypeSelected(BusinessTypeModel type) {
    if (!type.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا النشاط سيكون متاحاً قريباً'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Widget destinationScreen;

    switch (type.id) {
      case 'cafe':
        destinationScreen = CafeDetailsScreen(
          businessType: type.name,
          businessEmoji: type.emoji,
          businessId: type.id,
        );
        break;
      case 'restaurant':
        destinationScreen = RestaurantDetailsScreen(
          businessType: type.name,
          businessEmoji: type.emoji,
          businessId: type.id,
        );
        break;
      case 'grocery':
        destinationScreen = GroceryDetailsScreen(
          businessType: type.name,
          businessEmoji: type.emoji,
          businessId: type.id,
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هذا النشاط غير مدعوم حالياً')),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
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
                      'اختر نوع النشاط',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: context.cs.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.cs.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن نوع النشاط...',
                            border: InputBorder.none,
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                          color: AppColors.textSecondary,
                          iconSize: 20,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Business Types Grid
              Expanded(
                child: _filteredBusinessTypes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لم نجد نتائج',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: context.cs.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: _filteredBusinessTypes.length,
                        itemBuilder: (context, index) {
                          final type = _filteredBusinessTypes[index];
                          return BusinessTypeCard(
                            emoji: type.emoji,
                            name: type.name,
                            description: type.description,
                            color: type.color,
                            isAvailable: type.available,
                            onTap: () => _onBusinessTypeSelected(type),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
