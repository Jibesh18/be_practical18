import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/internship_model.dart';
import '../../routes/app_routes.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';

class EmployerProfileTab extends StatelessWidget {
  const EmployerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM     = context.watch<AuthViewModel>();
    final employerVM = context.watch<EmployerViewModel>();
    final user       = authVM.currentUser;
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),

          // ── Avatar + name ──
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                    (user?.displayName ?? 'E')[0].toUpperCase(),
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.primary),
                  )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  user?.displayName ?? 'Employer',
                  style: AppTextStyles.headlineMedium
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Employer',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Stats – live from Firestore ──
          if (user != null)
            StreamBuilder<List<InternshipModel>>(
              stream: employerVM.getMyListings(user.uid),
              builder: (context, snap) {
                final listings = snap.data ?? [];
                final active   = employerVM.getActiveListingCount(listings);
                return Row(
                  children: [
                    _StatTile(label: 'Total Posted', value: '${listings.length}'),
                    const SizedBox(width: 12),
                    _StatTile(label: 'Active',       value: '$active'),
                    const SizedBox(width: 12),
                    _StatTile(label: 'Paused',       value: '${listings.length - active}'),
                  ],
                );
              },
            ),

          const SizedBox(height: 28),


          _ProfileTile(
            icon: Iconsax.info_circle,
            label: 'Help & Support',
            onTap: () {},
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),

          _ProfileTile(
            icon: Iconsax.logout,
            label: 'Sign Out',
            color: AppColors.error,
            onTap: () async {
              await authVM.logout();
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
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
  final IconData   icon;
  final String     label;
  final VoidCallback onTap;
  final Color?     color;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: c, size: 20),
        title: Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: c, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: c.withOpacity(0.4), size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}