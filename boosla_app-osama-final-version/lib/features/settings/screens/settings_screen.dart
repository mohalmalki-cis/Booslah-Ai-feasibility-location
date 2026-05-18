import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../shared/widgets/background_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/settings_service.dart';
import 'profile_edit_screen.dart';

/// شاشة الإعدادات المحسّنة — الأسبوع الثامن/التاسع
/// أقسام: الملف الشخصي / إعدادات التحليل / عن التطبيق / تسجيل خروج

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SettingsService.isNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  // فتح شاشة تعديل الملف الشخصي
  Future<void> _openProfileEdit() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
    // AuthProvider يحدّث البيانات تلقائياً — لا حاجة لإعادة تحميل
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تسجيل الخروج',
          textAlign: TextAlign.right,
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('تسجيل خروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // AuthProvider يتولى تسجيل الخروج — RootGate يوجّه تلقائياً
      await context.read<AuthProvider>().logout();
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'عن تطبيق بوصلة',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('🧭', style: TextStyle(fontSize: 24)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'بوصلة هو تطبيق ذكي لمساعدة رواد الأعمال على اختيار الموقع المثالي لنشاطهم التجاري.',
              style: AppTextStyles.bodySmall.copyWith(height: 1.6),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            _buildAboutRow('الإصدار', '1.0.0'),
            _buildAboutRow('الجامعة', 'جامعة الملك سعود'),
            _buildAboutRow('السنة', '2025 - 2026'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value, style: AppTextStyles.bodySmall),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.cs.textSecondary,
            ),
          ),
        ],
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
              // ─── Header ──────────────────────────────────────────────
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
                      'الإعدادات',
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

              // ─── Content ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ── بطاقة الملف الشخصي ──────────────────
                      _buildProfileCard(),

                      const SizedBox(height: 24),

                      // ── إعدادات التطبيق ──────────────────────
                      _buildSectionHeader('إعدادات التطبيق'),
                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: context.cs.isDark
                              ? Icons.dark_mode
                              : Icons.light_mode_outlined,
                          iconColor: const Color(0xFF6366F1),
                          title: 'الوضع الداكن',
                          subtitle: context.cs.isDark ? 'مفعّل' : 'غير مفعّل',
                          trailing: Switch(
                            value: context.cs.isDark,
                            onChanged: (v) =>
                                context.read<ThemeProvider>().setDark(v),
                            activeThumbColor: AppColors.primary,
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'الإشعارات',
                          subtitle: 'تلقّي إشعارات عن آخر المستجدات',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (v) async {
                              setState(() => _notificationsEnabled = v);
                              await SettingsService.setNotifications(v);
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.language_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'اللغة',
                          subtitle: 'العربية',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'دعم اللغات الإضافية قريباً',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // ── عن التطبيق ───────────────────────────
                      _buildSectionHeader('عن التطبيق'),
                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: Icons.info_outline,
                          iconColor: const Color(0xFF10B981),
                          title: 'عن بوصلة',
                          subtitle: 'الإصدار 1.0.0',
                          onTap: _showAboutDialog,
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFF6B7280),
                          title: 'سياسة الخصوصية',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('سياسة الخصوصية قريباً'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // ── زر تسجيل الخروج ──────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout),
                              const SizedBox(width: 8),
                              Text(
                                'تسجيل الخروج',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  // ─── بطاقة الملف الشخصي ──────────────────────────────────────────────────
  Widget _buildProfileCard() {
    // اقرأ بيانات المستخدم من AuthProvider مباشرة
    final user = context.watch<AuthProvider>().user;

    return GestureDetector(
      onTap: _openProfileEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cs.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.cs.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // سهم
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: context.cs.textLight,
            ),

            const Spacer(),

            // البيانات
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user?.name.isNotEmpty == true ? user!.name : 'المستخدم',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.cs.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.cs.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.phone ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: context.cs.textLight,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // الصورة
            Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── عنوان القسم ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.cs.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ─── مجموعة إعدادات ──────────────────────────────────────────────────────
  Widget _buildSettingsGroup(List<_SettingsTile> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.cs.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length, (i) {
          final tile = tiles[i];
          final isLast = i == tiles.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: tile.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: tile.trailing,
                title: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    tile.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.cs.textPrimary,
                    ),
                  ),
                ),
                subtitle: tile.subtitle != null
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          tile.subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: context.cs.textSecondary,
                          ),
                        ),
                      )
                    : null,
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tile.iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tile.icon, color: tile.iconColor, size: 20),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: context.cs.border),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── نموذج بيانات عنصر الإعدادات ─────────────────────────────────────────
class _SettingsTile {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
}
