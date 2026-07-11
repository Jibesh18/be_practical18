import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String question;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int answerCount;

  CommunityPost({
    required this.id,
    required this.question,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.answerCount = 0,
  });

  factory CommunityPost.fromMap(String id, Map<String, dynamic> map) {
    return CommunityPost(
      id: id,
      question: map['question'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      answerCount: map['answerCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'answerCount': answerCount,
    };
  }

  /// Human-readable "X answers" label, replacing the old hardcoded string.
  String get answersLabel => answerCount == 1 ? '1 answer' : '$answerCount answers';
}