import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/root_gate.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/project_provider.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase — الأسبوع التاسع
  // نتحقق أولاً لتجنّب التهيئة المزدوجة عند إعادة التشغيل السريع (hot restart)
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider — يُدير حالة تسجيل الدخول عبر التطبيق
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Project Provider — يُدير مشاريع المستخدم (Firestore)
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        // Theme Provider — يُدير وضع الدارك / اللايت
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'بوصلة',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.mode,
          home: const RootGate(),
        ),
      ),
    );
  }
}
