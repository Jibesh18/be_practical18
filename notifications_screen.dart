import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/notification_provider.dart';
import '../components/common/notification_item.dart';
import '../components/common/loading_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primary),
            onPressed: () => ref.read(notificationActionProvider.notifier).markAllAsRead(),
          ),
          if (unreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.lg),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$unreadCount New', style: AppTextStyles.label.copyWith(color: AppColors.accent, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: ['All', 'Unread', 'Archive'].map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeFilter = filter),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5)),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))] : [],
                      ),
                      child: Text(filter, style: AppTextStyles.label.copyWith(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) => _buildList(notifications),
              loading: () => const LoadingWidget(),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> notifications) {
    final filtered = notifications.where((n) {
      if (_activeFilter == 'Unread') return !n.read;
      if (_activeFilter == 'Archive') return n.isArchived;
      return !n.isArchived;
    }).toList();

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.refresh(notificationsStreamProvider),
        color: AppColors.accent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(child: Text('🔔', style: TextStyle(fontSize: 48))),
            const SizedBox(height: 16),
            Center(child: Text('No notifications here', style: AppTextStyles.body.copyWith(color: AppColors.muted))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(notificationsStreamProvider),
      color: AppColors.accent,
      child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final notif = filtered[index];
        IconData icon = Icons.notifications_active_rounded;
        Color iconColor = AppColors.accent;

        switch (notif.type) {
          case 'internship':
            icon = Icons.work_rounded;
            iconColor = AppColors.primary;
            break;
          case 'xp':
            icon = Icons.star_rounded;
            iconColor = Colors.orange;
            break;
          case 'announcement':
            icon = Icons.campaign_rounded;
            iconColor = AppColors.secondary;
            break;
        }

        return Dismissible(
          key: Key(notif.id),
          direction: DismissDirection.horizontal,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.archive_rounded, color: AppColors.accent),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              ref.read(notificationActionProvider.notifier).archiveNotification(notif.id);
            } else {
              ref.read(notificationActionProvider.notifier).deleteNotification(notif.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => ref.read(notificationActionProvider.notifier).markAsRead(notif.id),
              child: NotificationItem(
                title: notif.title,
                description: notif.message,
                time: _formatTime(notif.time),
                icon: icon,
                iconColor: iconColor,
                isUnread: !notif.read,
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 30).ms);
      },
    ));
  }

  String _formatTime(String isoString) {
    try {
      final time = DateTime.parse(isoString);
      final diff = DateTime.now().difference(time);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hrs ago';
      } else {
        return '${diff.inDays} days ago';
      }
    } catch (e) {
      return isoString;
    }
  }
}
