import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/notification.dart';
import '../repo/notification_service.dart';

// 1. Provide the Repository
final notificationServiceProvider = Provider((ref) => NotificationService());

// 2. Real-time notifications stream from Firestore
// This will automatically update your UI whenever the database changes
final notificationsStreamProvider = StreamProvider<List<Notification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.notificationsStream;
});

// 3. Notifier for actions (Mark as read, Archive, etc.)
class NotificationActionNotifier extends StateNotifier<void> {
  final NotificationService _service;

  NotificationActionNotifier(this._service) : super(null);

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
  }

  Future<void> archiveNotification(String id) async {
    await _service.archiveNotification(id);
  }

  Future<void> unarchiveNotification(String id) async {
    await _service.unarchiveNotification(id);
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
  }
}

// 4. Provider for triggering actions
final notificationActionProvider = StateNotifierProvider<NotificationActionNotifier, void>((ref) {
  return NotificationActionNotifier(ref.watch(notificationServiceProvider));
});

// 5. Active notifications (Helper to filter out archived ones for the main list)
final activeNotificationsProvider = Provider<List<Notification>>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isArchived).toList(),
    orElse: () => [],
  );
});

// 6. Live Unread Count for the Badge
final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.read && !n.isArchived).length,
    orElse: () => 0,
  );
});
