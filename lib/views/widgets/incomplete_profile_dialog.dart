import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../tabs/profile_tab.dart';

/// Shows a dialog telling the user to complete their profile before
/// applying, and navigates them to the Profile screen if they choose to.
void showIncompleteProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Complete Your Profile', style: AppTextStyles.titleLarge),
      content: Text(
        'Please add your bio, education, and at least one skill before applying to internships. This helps employers get to know you.',
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            Navigator.pop(dialogContext);

            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileTab()),
            );
          },
          child: const Text('Go to Profile'),
        ),
      ],
    ),
  );
}