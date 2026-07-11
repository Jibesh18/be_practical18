import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_answer.dart';
import '../models/community_post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _db.collection('community_posts');

  CollectionReference<Map<String, dynamic>> _answersRef(String postId) =>
      _postsRef.doc(postId).collection('answers');

  /// Live stream of all posts, newest first.
  Stream<List<CommunityPost>> streamPosts() {
    return _postsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
          .map((d) => CommunityPost.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  Future<void> addPost({
    required String question,
    required String authorId,
    required String authorName,
  }) async {
    final post = CommunityPost(
      id: '',
      question: question,
      authorId: authorId,
      authorName: authorName,
      createdAt: DateTime.now(),
    );
    await _postsRef.add(post.toMap());
  }

  /// Live stream of answers for one post, oldest first (reads like a thread).
  Stream<List<CommunityAnswer>> streamAnswers(String postId) {
    return _answersRef(postId).orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
          .map((d) => CommunityAnswer.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  /// Adds an answer and atomically bumps the post's answerCount so the
  /// "X answers" label on the list screen stays accurate without a
  /// separate read.
  Future<void> addAnswer({
    required String postId,
    required String text,
    required String authorId,
    required String authorName,
  }) async {
    final answer = CommunityAnswer(
      id: '',
      text: text,
      authorId: authorId,
      authorName: authorName,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    final answerDoc = _answersRef(postId).doc();
    batch.set(answerDoc, answer.toMap());
    batch.update(_postsRef.doc(postId), {'answerCount': FieldValue.increment(1)});
    await batch.commit();
  }
}