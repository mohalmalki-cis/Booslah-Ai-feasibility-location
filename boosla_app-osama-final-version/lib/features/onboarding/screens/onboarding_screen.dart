import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_page.dart';
import '../../../core/storage/local_storage.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'emoji': '🧭',
      'title': 'مرحباً في بوصلة',
      'description': 'أداتك الذكية لاختيار الموقع المثالي لمشروعك التجاري',
    },
    {
      'emoji': '📍',
      'title': 'تحليل دقيق للمواقع',
      'description':
          'نحلل المواقع بناءً على عوامل متعددة لنساعدك في اتخاذ القرار الصحيح',
    },
    {
      'emoji': '📊',
      'title': 'نتائج واضحة',
      'description':
          'احصل على تقييم شامل ومقارنات تفصيلية بين المواقع المختلفة',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // حفظ أن المستخدم شاف الـ onboarding
      await LocalStorage.setOnboardingDone();

      if (!mounted) return;

      // الانتقال لصفحة تسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _skip() async {
    // حفظ أن المستخدم شاف الـ onboarding
    await LocalStorage.setOnboardingDone();

    if (!mounted) return;

    // الانتقال لصفحة تسجيل الدخول
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              if (_currentPage < _pages.length - 1)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _skip,
                      child: const Text('تخطي'),
                    ),
                  ),
                ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      emoji: _pages[index]['emoji']!,
                      title: _pages[index]['title']!,
                      description: _pages[index]['description']!,
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomButton(
                  text: _currentPage == _pages.length - 1
                      ? 'ابدأ الآن'
                      : 'التالي',
                  onPressed: _nextPage,
                  icon: _currentPage == _pages.length - 1
                      ? Icons.arrow_forward
                      : null,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
