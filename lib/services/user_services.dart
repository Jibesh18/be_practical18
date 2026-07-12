import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:convert';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required List<String> skills,
    String? education,
    String? experience,
    String? linkedinUrl,
    String? githubUrl,
    String? cvUrl,
  }) async {
    final data = <String, dynamic>{
      'name': name.trim(),
      'bio': bio.trim(),
      'skills': skills,
    };
    if (education != null) data['education'] = education.trim();
    if (experience != null) data['experience'] = experience.trim();
    if (linkedinUrl != null) data['linkedinUrl'] = linkedinUrl.trim();
    if (githubUrl != null) data['githubUrl'] = githubUrl.trim();
    if (cvUrl != null) data['cvUrl'] = cvUrl.trim();

    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<List<UserModel>> getApplicantProfiles(List<String> uids) async {
    if (uids.isEmpty) return [];
    final futures = uids.map((uid) => getUser(uid));
    final results = await Future.wait(futures);
    return results.whereType<UserModel>().toList();
  }

  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
  }
  static const int maxCvBytes = 700 * 1024; // ~700KB raw -> ~950KB base64, safely under Firestore's 1MB doc cap

  Future<void> uploadCvBase64({
    required String uid,
    required String base64Data,
    required String fileName,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('cv')
        .set({
      'data': base64Data,
      'fileName': fileName,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(uid).update({
      'cvUploaded': true,
      'cvFileName': fileName,
    });
  }

  Future<Map<String, dynamic>?> fetchCvData(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('cv')
        .get();
    return doc.exists ? doc.data() : null;
  }

  }