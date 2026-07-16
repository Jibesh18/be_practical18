import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/internship.dart';

class InternshipService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // The mock data has been moved to firestore_seeder.dart

  Future<List<Internship>> getAllInternships() async {
    final snapshot = await _db.collection('internships').get();
    return snapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList();
  }

  Future<Internship?> getById(String id) async {
    try {
      final doc = await _db.collection('internships').doc(id).get();
      if (doc.exists) return Internship.fromFirestore(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  // REAL FIREBASE ACTION: Apply for an internship and save to Firestore
  Future<void> applyToInternship(String internshipId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Please login first");

    final applicationData = {
      'internshipId': internshipId,
      'userId': user.uid,
      'appliedAt': FieldValue.serverTimestamp(),
      'status': 'Under Review',
    };

    // 1. Save to global applications collection
    await _db.collection('applications').add(applicationData);

    // 2. Save to user's private history
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('my_applications')
        .doc(internshipId)
        .set(applicationData);

    // 3. Trigger a notification in Firestore
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
      'type': 'internship',
      'title': 'Application Received',
      'message': 'Your application for internship #$internshipId has been sent successfully.',
      'time': DateTime.now().toIso8601String(),
      'read': false,
      'isArchived': false,
    });
  }

  Future<List<Internship>> getTrendingInternships() async {
    final snapshot = await _db.collection('internships').where('trending', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList();
  }

  Future<List<Internship>> filterInternships(String category) async {
    if (category == 'all') return getAllInternships();
    
    // Convert 'remote' or other categories
    String formattedType = category[0].toUpperCase() + category.substring(1);
    final snapshot = await _db.collection('internships').where('type', isEqualTo: formattedType).get();
    return snapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList();
  }

  Future<List<Internship>> searchInternships(String query) async {
    // Firestore doesn't have great text search natively without extensions,
    // so we'll fetch all and filter in memory for this demo scale.
    final all = await getAllInternships();
    final lowerQuery = query.toLowerCase();
    return all.where((i) =>
        i.position.toLowerCase().contains(lowerQuery) ||
        i.company.toLowerCase().contains(lowerQuery) ||
        i.skills.any((s) => s.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  Future<List<Map<String, dynamic>>> getUserApplications() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    final snapshot = await _db.collection('users').doc(user.uid).collection('my_applications').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<bool> hasUserApplied(String internshipId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final doc = await _db.collection('users').doc(user.uid).collection('my_applications').doc(internshipId).get();
    return doc.exists;
  }
}
