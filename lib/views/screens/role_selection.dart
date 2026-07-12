import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Shown when a user signs in with Google but has no role in Firestore yet.
/// They pick their role here, it gets saved, then they're routed correctly.
class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String uid;

  const RoleSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'internSeeker' or 'employer'
  bool _saving = false;

  Future<void> _confirm() async {
    if (_selectedRole == null || _saving) return;

    setState(() => _saving = true);

    final authVM = context.read<AuthViewModel>();
    await authVM.saveRole(
      uid: widget.uid,
      name: widget.name,
      email: widget.email,
      role: _selectedRole!,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (_selectedRole == 'employer') {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.employerHome, (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.internHome, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                'One last step 👋',
                style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Hi ${widget.name.split(' ').first}! How will you be using Be Practical?',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Intern Seeker card
              _RoleCard(
                selected: _selectedRole == 'internSeeker',
                icon: Iconsax.teacher,
                title: 'Intern Seeker',
                subtitle: 'Find internships, build your profile, apply to opportunities',
                bullets: ['Browse internships', 'AI-powered career matching', 'Track your applications'],
                color: AppColors.primary,
                onTap: () => setState(() => _selectedRole = 'internSeeker'),
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // Employer card
              _RoleCard(
                selected: _selectedRole == 'employer',
                icon: Iconsax.building,
                title: 'Employer',
                subtitle: 'Post internships and find the right candidates for your team',
                bullets: ['Post internships', 'Manage applicants', 'AI candidate suggestions'],
                color: const Color(0xFF10B981),
                onTap: () => setState(() => _selectedRole = 'employer'),
                isDark: isDark,
              ),

              const SizedBox(height: 40),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_selectedRole == null || _saving) ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(
                    _selectedRole == null ? 'Select a role to continue' : 'Continue as ${_selectedRole == 'employer' ? 'Employer' : 'Intern Seeker'}',
                    style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Signed in as
              Center(
                child: Text(
                  'Signed in as ${widget.email}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.06)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: selected ? color : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      )),
                  const SizedBox(height: 12),
                  ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_rounded, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(b, style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? color : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}