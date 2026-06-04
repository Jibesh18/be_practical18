import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/notification.dart' as model;

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REAL-TIME: Listen to the user's notification collection
  Stream<List<model.Notification>> get notificationsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return model.Notification(
          id: doc.id,
          type: data['type'] ?? 'info',
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          time: data['time'] ?? 'Just now',
          read: data['read'] ?? false,
          isArchived: data['isArchived'] ?? false,
        );
      }).toList();
    });
  }

  Future<void> markAsRead(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(id)
        .update({'read': true});
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final notifications = await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    
    final batch = _db.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> archiveNotification(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(id)
        .update({'isArchived': true});
  }

  // ADDED: Missing unarchive method
  Future<void> unarchiveNotification(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(id)
        .update({'isArchived': false});
  }
}
