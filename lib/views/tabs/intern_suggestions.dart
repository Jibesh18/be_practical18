import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/internship_model.dart';
import '../../models/user_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import 'profile_tab.dart';

const _kAiAccent = Color(0xFF3B82F6); // same blue accent used elsewhere

class InternAiSuggestionsTab extends StatelessWidget {
  const InternAiSuggestionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authVM = context.watch<AuthViewModel>();
    final internVM = context.watch<InternshipViewModel>();
    final user = authVM.currentUser;

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return SafeArea(
      child: StreamBuilder<UserModel?>(
        stream: authVM.watchUserProfile(user.uid),
        builder: (context, userSnap) {
          final userModel = userSnap.data;

          return StreamBuilder<List<InternshipModel>>(
            stream: internVM.allInternships,
            builder: (context, listSnap) {
              final internships = listSnap.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _Header(isDark: isDark),
                  const SizedBox(height: 20),

                  if (userModel == null)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ))
                  else if (!_hasEnoughProfile(userModel))
                    _IncompleteProfileCard(isDark: isDark)
                  else
                    _SuggestionsPanel(
                      userModel: userModel,
                      internships: internships,
                      isDark: isDark,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _hasEnoughProfile(UserModel u) =>
      u.bio.isNotEmpty || u.education.isNotEmpty || u.skills.isNotEmpty;
}

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _kAiAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Iconsax.magic_star, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Suggestions',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
              Text('Matched to your CV and skills',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncompleteProfileCard extends StatelessWidget {
  final bool isDark;
  const _IncompleteProfileCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(Iconsax.document_text, size: 40,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          const SizedBox(height: 12),
          Text('Add your CV to get matched',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Fill in your bio, education, experience, and skills in your profile '
                'so the AI can suggest internships that actually fit you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileTab()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAiAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Complete my profile'),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  final UserModel userModel;
  final List<InternshipModel> internships;
  final bool isDark;
  const _SuggestionsPanel({
    required this.userModel,
    required this.internships,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InternshipViewModel>();
    final hasResult = vm.aiSuggestionResult != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasResult ? _kAiAccent.withOpacity(0.3) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasResult && !vm.isAiSuggestionLoading) ...[
            Text(
              'Ready when you are — the AI will read your bio, education, '
                  'experience, and skills, and match them against the '
                  '${internships.length} internship${internships.length == 1 ? '' : 's'} currently open.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: internships.isEmpty
                    ? null
                    : () => context.read<InternshipViewModel>().getAISuggestionsForUser(
                  user: userModel,
                  internships: internships,
                ),
                icon: const Icon(Iconsax.magic_star, size: 18),
                label: Text(internships.isEmpty ? 'No internships open right now' : 'Get my suggestions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAiAccent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (vm.isAiSuggestionLoading) ...[
            Row(
              children: [
                const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _kAiAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                child: Text('Matching your profile against open roles...',
                    style: AppTextStyles.bodyMedium.copyWith(color: _kAiAccent)),
                )
                  ],
            ),
          ] else ...[
            Text(
              vm.aiSuggestionResult!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () => context.read<InternshipViewModel>().getAISuggestionsForUser(
                user: userModel,
                internships: internships,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh suggestions'),
              style: TextButton.styleFrom(foregroundColor: _kAiAccent, padding: EdgeInsets.zero),
            ),
          ],
        ],
      ),
    );
  }
}