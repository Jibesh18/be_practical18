import 'package:flutter/material.dart';
import '../models/community_post.dart';

class CommunityViewModel extends ChangeNotifier {
  final List<CommunityPost> _posts = [
    CommunityPost(question: 'How to prepare for Data Analyst interviews?', author: 'Sarah K.', answers: '24 answers'),
    CommunityPost(question: 'Anyone got selected in TechNepal Flutter Internship?', author: 'Rohan P.', answers: '12 answers'),
    CommunityPost(question: 'Best resources to learn Power BI?', author: 'Anita Sharma', answers: '8 answers'),
  ];

  List<CommunityPost> get posts => _posts;

  void addPost(String question) {
    _posts.insert(
      0,
      CommunityPost(
        question: question,
        author: 'You',
        answers: '0 answers',
      ),
    );
    notifyListeners();
  }
}