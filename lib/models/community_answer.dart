import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityAnswer {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  CommunityAnswer({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory CommunityAnswer.fromMap(String id, Map<String, dynamic> map) {
    return CommunityAnswer(
      id: id,
      text: map['text'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}