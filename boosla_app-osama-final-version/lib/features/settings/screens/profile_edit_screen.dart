import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../core/providers/auth_provider.dart';

/// شاشة تعديل الملف الشخصي — الأسبوع التاسع (Firebase)
/// تتيح للمستخدم تعديل الاسم ورقم الجوال وحفظها في Firestore

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    // اقرأ البيانات من AuthProvider مباشرة
    _loadFromProvider();
  }

  void _loadFromProvider() {
    final user = context.read<AuthProvider>().user;
    _nameController.text  = user?.name  ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // حفظ في Firestore عبر AuthProvider
    final success = await context.read<AuthProvider>().updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✅ تم حفظ الملف الشخصي' : '❌ فشل الحفظ'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context, true); // نُرجع true كإشارة للتحديث
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                    ),
                    const Spacer(),
                    Text(
                      'تعديل الملف الشخصي',
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

              Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // ── صورة الملف الشخصي ──────────────────────
                          _buildAvatar(),

                          const SizedBox(height: 32),

                          // ── الحقول ─────────────────────────────────
                          _buildField(
                            controller: _nameController,
                            label: 'الاسم الكامل',
                            hint: 'أدخل اسمك الكامل',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'الاسم مطلوب'
                                    : null,
                          ),

                          const SizedBox(height: 16),

                          _buildField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            hint: 'example@ksu.edu.sa',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'البريد الإلكتروني مطلوب';
                              }
                              if (!v.contains('@')) {
                                return 'أدخل بريداً إلكترونياً صحيحاً';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildField(
                            controller: _phoneController,
                            label: 'رقم الجوال',
                            hint: '+966 5X XXX XXXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'رقم الجوال مطلوب'
                                    : null,
                          ),

                          const SizedBox(height: 40),

                          // ── زر الحفظ ───────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'حفظ التغييرات',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── صورة الملف الشخصي ────────────────────────────────────────────────────
  Widget _buildAvatar() {
    return Stack(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.person, size: 60, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('رفع الصور سيكون متاحاً قريباً'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── حقل إدخال ────────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        validator: validator,
        style: AppTextStyles.bodyMedium.copyWith(color: context.cs.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: context.cs.textSecondary,
          ),
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: context.cs.textLight,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          filled: true,
          fillColor: context.cs.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
