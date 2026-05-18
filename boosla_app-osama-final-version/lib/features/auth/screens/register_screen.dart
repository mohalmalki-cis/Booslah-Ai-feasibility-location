import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

/// شاشة إنشاء الحساب — الأسبوع التاسع (Firebase Auth)

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
    );

    // الـ RootGate يوجّه تلقائياً عند النجاح
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
                const SizedBox(height: 40),

                // ── Header ────────────────────────────────────────────────
                Text(
                  'بوصلة 🧭',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'أنشئ حسابك الآن',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: context.cs.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ── الاسم ─────────────────────────────────────────────────
                CustomTextField(
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل اسمك الكامل' : null,
                ),

                const SizedBox(height: 16),

                // ── البريد الإلكتروني ──────────────────────────────────────
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

                // ── رقم الجوال ────────────────────────────────────────────
                CustomTextField(
                  label: 'رقم الجوال',
                  hint: '+966 5X XXX XXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل رقم الجوال' : null,
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

                const SizedBox(height: 16),

                // ── تأكيد كلمة المرور ─────────────────────────────────────
                CustomTextField(
                  label: 'تأكيد كلمة المرور',
                  hint: '••••••••',
                  controller: _confirmController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أكّد كلمة المرور';
                    if (v != _passwordController.text) return 'كلمة المرور غير متطابقة';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ── زر إنشاء الحساب ───────────────────────────────────────
                CustomButton(
                  text: 'إنشاء الحساب',
                  onPressed: isLoading ? null : () { _handleRegister(); },
                  isLoading: isLoading,
                ),

                const SizedBox(height: 16),

                // ── رابط تسجيل الدخول ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('لديك حساب بالفعل؟ ', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('سجّل دخولك'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
