import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import '../widgets/internship_card.dart';

class InternSearchTab extends StatelessWidget {
  const InternSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final internVM = context.watch<InternshipViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: internVM.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by title, company, skill...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: internVM.searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: internVM.clearFilters,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: AppColors.lightBorder),
                ),
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final type in ['All', 'Remote', 'On-site', 'Hybrid'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: internVM.selectedType == type,
                      onSelected: (_) => internVM.setType(type),
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: internVM.selectedType == type
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Results
          Expanded(
            child: StreamBuilder(
              stream: internVM.allInternships,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading internships',
                          style: AppTextStyles.bodyMedium));
                }
                final all = snapshot.data ?? [];
                final filtered = internVM.applyFilters(all);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.lightTextTertiary),
                        const SizedBox(height: 12),
                        Text('No internships found',
                            style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: internVM.clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final internship = filtered[index];
                    return InternshipCard(
                      internship: internship,
                      showApplyButton: true,
                      onApply: user == null
                          ? null
                          : () async {
                        final vm = context.read<InternshipViewModel>();
                        final success = await vm.apply(
                          internship: internship,
                          applicantId: user.uid,
                          applicantName:
                          user.displayName ?? 'Anonymous',
                          applicantEmail: user.email ?? '',
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Applied successfully! 🎉'
                                : vm.applyError ??
                                'Something went wrong'),
                            backgroundColor: success
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        );
                      },
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