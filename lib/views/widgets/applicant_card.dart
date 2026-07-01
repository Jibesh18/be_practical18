import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/employer_viewmodel.dart';

/// Reusable applicant card for all employer screens.
///
/// [compact] = true  → slim row tile used in the dashboard's "Recent Applications"
/// [compact] = false → full card with action buttons used in the Applicants tab
class ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final EmployerViewModel vm;
  final bool compact;

  const ApplicantCard({
    super.key,
    required this.application,
    required this.vm,
    this.compact = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':    return AppColors.success;
      case 'rejected':    return AppColors.error;
      case 'shortlisted': return AppColors.warning;
      case 'reviewed':    return AppColors.secondary;
      default:            return AppColors.lightTextTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _statusColor(application.status);
    final isPending = application.status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── Avatar ───────────────────────────────────────────────────
              CircleAvatar(
                radius: compact ? 18 : 22,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  application.applicantName.isNotEmpty
                      ? application.applicantName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 14 : 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Name + subtitle ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // Compact mode: show which internship they applied to
                      // Full mode: show their email
                      compact
                          ? application.internshipTitle
                          : application.applicantEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Status badge ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  vm.getStatusLabel(application.status),
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),

          // ── Action buttons — only in full mode and only for pending ───────
          if (!compact && isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionBtn(
                  label: 'Accept',
                  color: AppColors.success,
                  onTap: () => vm.acceptApplicant(application.id),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Shortlist',
                  color: AppColors.warning,
                  onTap: () => vm.shortlistApplicant(application.id),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Reject',
                  color: AppColors.error,
                  onTap: () => vm.rejectApplicant(application.id),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}