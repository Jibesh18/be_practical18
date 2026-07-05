import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, resume }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? fileName;
  final String? fileUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.fileName,
    this.fileUrl,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      fileName: data['fileName'],
      fileUrl: data['fileUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'fileName': fileName,
      'fileUrl': fileUrl,
    };
  }
}

class ChatRoom {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, dynamic> participantInfo; // Metadata for UI (names, avatars)
  final Map<String, int> unreadCounts;

  ChatRoom({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.participantInfo,
    required this.unreadCounts,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participantInfo: data['participantInfo'] ?? {},
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }
}

