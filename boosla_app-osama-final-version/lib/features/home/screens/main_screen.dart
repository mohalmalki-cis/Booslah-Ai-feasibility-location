import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../../business_selection/screens/analysis_history_screen.dart';
import '../../map/screens/map_screen.dart';
import '../../comparison/screens/comparison_screen.dart';

/// الشاشة الرئيسية الأم — تدير الـ bottom navigation لجميع التابات
/// باستخدام IndexedStack لحفظ حالة كل شاشة عند التبديل
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // الرئيسية هي الافتراضية

  final List<Widget> _screens = const [
    AnalysisHistoryScreen(), // 0 - التحليل
    HomeScreen(),            // 1 - الرئيسية
    MapScreen(),             // 2 - الخريطة
    ComparisonScreen(),      // 3 - المقارنة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
