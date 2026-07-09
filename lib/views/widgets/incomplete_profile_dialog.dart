import 'package:flutter/material.dart';

/// Shows a dialog telling the user to complete their profile before applying.
/// Pass [onGoToProfile] callback to navigate to the profile screen.
void showIncompleteProfileDialog(
    BuildContext context, {
      VoidCallback? onGoToProfile,
    }) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Complete Your Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Please add your bio, education, and at least one skill '
                'before applying. This helps employers get to know you better.',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const _CheckRow(icon: Icons.person_outline_rounded,   label: 'Bio / About me'),
          const SizedBox(height: 8),
          const _CheckRow(icon: Icons.school_outlined,          label: 'Education details'),
          const SizedBox(height: 8),
          const _CheckRow(icon: Icons.code_rounded,             label: 'At least one skill'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Later', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(dialogContext);
            onGoToProfile?.call();
          },
          child: const Text('Complete Profile'),
        ),
      ],
    ),
  );
}

class _CheckRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CheckRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Icon(Icons.arrow_forward_rounded,
            size: 14, color: Theme.of(context).primaryColor),
      ],
    );
  }
}