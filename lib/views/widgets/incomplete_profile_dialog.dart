import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

/// Shows a dialog telling the user to complete their profile before
/// applying, and navigates them to the Profile tab if they choose to.
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
            Navigator.of(context).popUntil((route) => route.isFirst);
            context.read<DashboardViewModel>().setIndex(4); // Profile tab
          },
          child: const Text('Go to Profile'),
        ),
      ],
    ),
  );
}