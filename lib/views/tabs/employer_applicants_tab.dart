import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';

class EmployerApplicantsTab extends StatelessWidget {
  const EmployerApplicantsTab({super.key});

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
                Text('Applicants', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Review and manage candidates',
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
                : StreamBuilder<List<ApplicationModel>>(
              stream: employerVM.getAllMyApplicants(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final apps = snapshot.data ?? [];
                if (apps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 56,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                        const SizedBox(height: 16),
                        Text('No applicants yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            )),
                      ],
                    ),
                  );
                }

                // Group applications by internship title
                final grouped = <String, List<ApplicationModel>>{};
                for (final app in apps) {
                  grouped
                      .putIfAbsent(app.internshipTitle, () => [])
                      .add(app);
                }

                return ListView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: AppTextStyles.titleMedium,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${entry.value.length} applicant${entry.value.length != 1 ? 's' : ''}',
                                  style:
                                  AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map((app) => _ApplicantCard(
                          application: app,
                          employerVM: employerVM,
                        )),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final EmployerViewModel employerVM;

  const _ApplicantCard({
    required this.application,
    required this.employerVM,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPending = application.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(
              application.applicantName.isNotEmpty
                  ? application.applicantName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.applicantName,
                    style: AppTextStyles.titleMedium),
                Text(application.applicantEmail,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge or action buttons
          if (!isPending)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:
                _statusColor(application.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.status[0].toUpperCase() +
                    application.status.substring(1),
                style: AppTextStyles.labelSmall.copyWith(
                  color: _statusColor(application.status),
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reject button
                _ActionBtn(
                  icon: Icons.close_rounded,
                  color: AppColors.error,
                  tooltip: 'Reject',
                  onTap: () => employerVM
                      .rejectApplicant(application.id),
                ),
                const SizedBox(width: 6),
                // Accept button
                _ActionBtn(
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  tooltip: 'Accept',
                  onTap: () => employerVM
                      .acceptApplicant(application.id),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}