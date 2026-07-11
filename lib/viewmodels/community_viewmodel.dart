import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/community_answer.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityService _service;
  final FirebaseAuth _auth;

  CommunityViewModel({
    CommunityService? service,
    FirebaseAuth? auth,
  })  : _service = service ?? CommunityService(),
        _auth = auth ?? FirebaseAuth.instance;

  bool _isPosting = false;
  String? _postError;
  bool get isPosting => _isPosting;
  String? get postError => _postError;

  bool _isAnswering = false;
  String? _answerError;
  bool get isAnswering => _isAnswering;
  String? get answerError => _answerError;

  /// Live stream of all questions, for the community feed.
  Stream<List<CommunityPost>> get posts => _service.streamPosts();

  /// Live stream of answers for one question, for the detail screen.
  Stream<List<CommunityAnswer>> answersFor(String postId) =>
      _service.streamAnswers(postId);

  Future<bool> addPost(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      _postError = 'Please enter a question.';
      notifyListeners();
      return false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _postError = 'You need to be signed in to post.';
      notifyListeners();
      return false;
    }

    _isPosting = true;
    _postError = null;
    notifyListeners();

    try {
      await _service.addPost(
        question: trimmed,
        authorId: user.uid,
        authorName: user.displayName?.isNotEmpty == true ? user.displayName! : 'Anonymous',
      );
      return true;
    } catch (e) {
      _postError = 'Failed to post your question. Please try again.';
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  Future<bool> addAnswer({required String postId, required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final user = _auth.currentUser;
    if (user == null) {
      _answerError = 'You need to be signed in to answer.';
      notifyListeners();
      return false;
    }

    _isAnswering = true;
    _answerError = null;
    notifyListeners();

    try {
      await _service.addAnswer(
        postId: postId,
        text: trimmed,
        authorId: user.uid,
        authorName: user.displayName?.isNotEmpty == true ? user.displayName! : 'Anonymous',
      );
      return true;
    } catch (e) {
      _answerError = 'Failed to post your answer. Please try again.';
      return false;
    } finally {
      _isAnswering = false;
      notifyListeners();
    }
  }
}