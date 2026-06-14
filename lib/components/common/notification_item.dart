import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';
import '../cards/primary_card.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;
  final VoidCallback? onDismiss;

  const NotificationItem({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isUnread = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: Key(title + time),
        onDismissed: (_) => onDismiss?.call(),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
        ),
        child: PrimaryCard(
          color: isUnread ? AppColors.accent.withValues(alpha: 0.03) : Colors.white,
          showBorder: isUnread,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
            children: [
            Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),