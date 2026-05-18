import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// شاشة تسجيل الدخول — الأسبوع التاسع (Firebase Auth)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // الـ RootGate يتعامل مع التوجيه تلقائياً عند نجاح تسجيل الدخول
    if (!success && mounted) {
      _showError(authProvider.errorMessage ?? 'حدث خطأ');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: context.cs.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // ── Logo ─────────────────────────────────────────────────
                Text(
                  '🧭',
                  style: const TextStyle(fontSize: 64),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'بوصلة',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'أهلاً بعودتك',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: context.cs.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // ── البريد الإلكتروني ─────────────────────────────────────
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل البريد الإلكتروني';
                    if (!v.contains('@')) return 'صيغة البريد غير صحيحة';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── كلمة المرور ───────────────────────────────────────────
                CustomTextField(
                  label: 'كلمة المرور',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                    if (v.length < 6) return 'كلمة المرور قصيرة (6 أحرف على الأقل)';
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // ── نسيت كلمة المرور ──────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ),

                const SizedBox(height: 24),

                // ── زر الدخول ─────────────────────────────────────────────
                CustomButton(
                  text: 'تسجيل الدخول',
                  onPressed: isLoading ? null : () { _handleLogin(); },
                  isLoading: isLoading,
                ),

                const SizedBox(height: 16),

                // ── رابط إنشاء حساب ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟ ', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('سجّل الآن'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
