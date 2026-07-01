import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/application_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';
import '../widgets/applicant_card.dart';

class EmployerApplicantsTab extends StatelessWidget {
  const EmployerApplicantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployerViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Applicants',
                    style: AppTextStyles.headlineMedium
                        .copyWith(fontWeight: FontWeight.w800)),
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
              stream: vm.getAllMyApplicants(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final apps = snap.data ?? [];

                if (apps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.people,
                            size: 56,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                        const SizedBox(height: 16),
                        Text(
                          'No applicants yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group by internship title
                final grouped = <String, List<ApplicationModel>>{};
                for (final app in apps) {
                  grouped
                      .putIfAbsent(app.internshipTitle, () => [])
                      .add(app);
                }

                return ListView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
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
                                child: Text(entry.key,
                                    style:
                                    AppTextStyles.titleMedium),
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
                                  style: AppTextStyles.labelSmall
                                      .copyWith(
                                      color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ✅ ApplicantCard with compact: false
                        // shows full card with action buttons
                        ...entry.value.map(
                              (app) => ApplicantCard(
                            application: app,
                            vm: vm,
                            compact: false,
                          ),
                        ),
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