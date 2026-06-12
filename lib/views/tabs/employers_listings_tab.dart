import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';

class EmployerListingsTab extends StatelessWidget {
  const EmployerListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final employerVM = context.watch<EmployerViewModel>();
    final user = context.watch<AuthViewModel>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Listings', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Manage your posted internships',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: user == null
                ? const Center(child: Text('Not logged in'))
                : StreamBuilder<List<InternshipModel>>(
              stream: employerVM.getMyListings(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final listings = snapshot.data ?? [];
                if (listings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline_rounded,
                            size: 56,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                        const SizedBox(height: 16),
                        Text("You haven't posted any internships yet",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            )),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Switch to Post tab — parent controls index
                            // Use a callback or just hint to user
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Post an internship'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    return _ListingCard(
                      internship: listings[index],
                      employerVM: employerVM,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final InternshipModel internship;
  final EmployerViewModel employerVM;

  const _ListingCard({
    required this.internship,
    required this.employerVM,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + status badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(internship.title,
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(internship.company,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        )),
                  ],
                ),
              ),
              // Active / Paused toggle badge
              GestureDetector(
                onTap: () => employerVM.toggleStatus(
                    internship.id, internship.isActive),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: internship.isActive
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        internship.isActive
                            ? Icons.circle
                            : Icons.pause_circle_outline_rounded,
                        size: 8,
                        color: internship.isActive
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        internship.isActive ? 'Active' : 'Paused',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: internship.isActive
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Details chips
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Chip(
                  icon: Icons.location_on_outlined,
                  label: internship.location),
              _Chip(
                  icon: Icons.access_time_rounded,
                  label: internship.duration),
              _Chip(
                  icon: Icons.currency_rupee_rounded,
                  label: internship.stipend),
              _Chip(
                  icon: Icons.wifi_rounded,
                  label: internship.type),
            ],
          ),
          if (internship.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: internship.skills
                  .take(4)
                  .map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(s,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
              ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      employerVM.toggleStatus(internship.id, internship.isActive),
                  icon: Icon(
                    internship.isActive
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 16,
                  ),
                  label: Text(internship.isActive ? 'Pause' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: internship.isActive
                        ? AppColors.warning
                        : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Internship?'),
        content: Text(
            'Are you sure you want to delete "${internship.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              employerVM.deleteInternship(internship.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 12,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            )),
      ],
    );
  }
}