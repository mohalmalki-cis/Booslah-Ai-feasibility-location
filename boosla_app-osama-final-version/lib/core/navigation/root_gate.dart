import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../storage/local_storage.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/auth/screens/login_screen.dart';

/// RootGate — الأسبوع التاسع
/// يستمع لـ Firebase Auth عبر AuthProvider ويوجّه للشاشة الصحيحة
/// الأولوية: Onboarding → Login → MainScreen

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // ── تحميل أولي ─────────────────────────────────────────────────────────
    if (authProvider.status == AuthStatus.initial ||
        authProvider.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ── مسجّل دخول ─────────────────────────────────────────────────────────
    if (authProvider.isAuthenticated) {
      return const MainScreen();
    }

    // ── غير مسجّل — تحقق من Onboarding ────────────────────────────────────
    return FutureBuilder<bool>(
      future: LocalStorage.hasSeenOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // شاف Onboarding → صفحة Login | لم يشاهده → Onboarding
        return snapshot.data == true
            ? const LoginScreen()
            : const OnboardingScreen();
      },
    );
  }
}
