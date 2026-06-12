import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';
import '../../models/internship_model.dart';

class EmployerProfileTab extends StatelessWidget {
  const EmployerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final employerVM = context.watch<EmployerViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    user?.displayName?.isNotEmpty == true
                        ? user!.displayName![0].toUpperCase()
                        : 'E',
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Employer',
                    style: AppTextStyles.titleLarge),
                Text(user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    )),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Employer',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Stats row — live from Firestore
          if (user != null)
            StreamBuilder<List<InternshipModel>>(
              stream: employerVM.getMyListings(user.uid),
              builder: (context, snapshot) {
                final listings = snapshot.data ?? [];
                final active =
                    listings.where((l) => l.isActive).length;
                return Row(
                  children: [
                    _StatCard(
                        label: 'Total Posted', value: '${listings.length}'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Active', value: '$active'),
                    const SizedBox(width: 12),
                    _StatCard(
                        label: 'Paused',
                        value: '${listings.length - active}'),
                  ],
                );
              },
            ),
          const SizedBox(height: 28),

          // Settings
          _ProfileTile(
              icon: Icons.business_outlined,
              label: 'Company Profile',
              onTap: () {}),
          _ProfileTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {}),
          _ProfileTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () {}),
          const Divider(height: 32),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: AppColors.error,
            onTap: () async {
              await authVM.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (r) => false);
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileTile(
      {required this.icon,
        required this.label,
        required this.onTap,
        this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c),
      title: Text(label,
          style: AppTextStyles.bodyLarge.copyWith(color: c)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.lightTextTertiary),
      onTap: onTap,
    );
  }
}