import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

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
}