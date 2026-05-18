import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

/// شاشة إعادة تعيين كلمة المرور — الأسبوع التاسع

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(_emailController.text);

    if (success && mounted) {
      setState(() => _emailSent = true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'حدث خطأ'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: context.cs.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessState() : _buildFormState(isLoading),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          const Text('🔑', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),

          const SizedBox(height: 20),

          Text(
            'نسيت كلمة المرور؟',
            style: AppTextStyles.headingLarge.copyWith(color: context.cs.primaryText),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
            style: AppTextStyles.bodyMedium.copyWith(color: context.cs.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

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

          const SizedBox(height: 32),

          CustomButton(
            text: 'إرسال رابط الاسترداد',
            onPressed: isLoading ? null : () { _handleReset(); },
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('✅', style: TextStyle(fontSize: 72), textAlign: TextAlign.center),

        const SizedBox(height: 24),

        Text(
          'تم إرسال الرابط!',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.success),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة مرورك',
          style: AppTextStyles.bodyMedium.copyWith(color: context.cs.textSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            'العودة لتسجيل الدخول',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
