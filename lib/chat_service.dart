import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // --- Chat Rooms ---
  Stream<List<ChatRoom>> streamChatRooms() {
    return _db
        .collection('chat_rooms')
        .where('participantIds', arrayContains: _uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  // --- Typing Indicators ---
  Stream<bool> streamTypingStatus(String roomId, String otherId) {
    return _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('typing_status')
        .doc(otherId)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['isTyping'] ?? false) : false);
  }

  Future<void> setTypingStatus(String roomId, bool isTyping) async {
    await _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('typing_status')
        .doc(_uid)
        .set({'isTyping': isTyping, 'lastUpdate': FieldValue.serverTimestamp()});
  }

  // --- Messages ---
  Stream<List<Message>> streamMessages(String roomId) {
    return _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(String roomId, String receiverId, String content, {MessageType type = MessageType.text, String? fileName, String? fileUrl}) async {
    final messageData = {
      'senderId': _uid,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'fileName': fileName,
      'fileUrl': fileUrl,
    };

    final batch = _db.batch();
    
    // 1. Add message
    final msgRef = _db.collection('chat_rooms').doc(roomId).collection('messages').doc();
    batch.set(msgRef, messageData);

    // 2. Update Room Metadata
    batch.update(_db.collection('chat_rooms').doc(roomId), {
      'lastMessage': type == MessageType.text ? content : 'Sent an attachment',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.$receiverId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> markAsRead(String roomId) async {
    await _db.collection('chat_rooms').doc(roomId).update({
      'unreadCounts.$_uid': 0,
    });
    
    // Mark individual messages as read (Optional: for individual read receipts)
    final unreadMsgs = await _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('receiverId', isEqualTo: _uid)
        .where('isRead', isEqualTo: false)
        .get();
        
    if (unreadMsgs.docs.isNotEmpty) {
      final batch = _db.batch();
      for (var doc in unreadMsgs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  Future<String> getOrCreateChatRoom(String otherId, Map<String, dynamic> otherInfo) async {
    final existing = await _db
        .collection('chat_rooms')
        .where('participantIds', arrayContains: _uid)
        .get();

    for (var doc in existing.docs) {
      final ids = List<String>.from(doc.data()['participantIds']);
      if (ids.contains(otherId)) return doc.id;
    }

    final newRoomRef = _db.collection('chat_rooms').doc();
    final myDoc = await _db.collection('users').doc(_uid).get();
    final myData = myDoc.data() as Map<String, dynamic>;

    await newRoomRef.set({
      'participantIds': [_uid, otherId],
      'lastMessage': 'Conversation started',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participantInfo': {
        _uid: {'name': myData['name'], 'avatar': myData['avatar']},
        otherId: otherInfo,
      },
      'unreadCounts': {_uid: 0, otherId: 0},
    });

    return newRoomRef.id;
  }
}

