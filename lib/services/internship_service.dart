import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';

class InternshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Post a new internship
  Future<void> postInternship(InternshipModel internship) async {
    await _firestore.collection('internships').add(internship.toMap());
  }

  // Get all active internships (for intern seeker)
  Stream<List<InternshipModel>> getAllInternships() {
    return _firestore
        .collection('internships')
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => InternshipModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get internships posted by a specific employer
  Stream<List<InternshipModel>> getEmployerInternships(String employerId) {
    return _firestore
        .collection('internships')
        .where('postedBy', isEqualTo: employerId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => InternshipModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Apply to an internship
  Future<void> applyToInternship(ApplicationModel application) async {
    await _firestore.collection('applications').add(application.toMap());
  }

  // Check if user already applied
  Future<bool> hasApplied(String internshipId, String userId) async {
    final snap = await _firestore
        .collection('applications')
        .where('internshipId', isEqualTo: internshipId)
        .where('applicantId', isEqualTo: userId)
        .get();
    return snap.docs.isNotEmpty;
  }

  // Get applications for an intern
  Stream<List<ApplicationModel>> getMyApplications(String userId) {
    return _firestore
        .collection('applications')
        .where('applicantId', isEqualTo: userId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get applicants for an employer's internship
  Stream<List<ApplicationModel>> getApplicants(String internshipId) {
    return _firestore
        .collection('applications')
        .where('internshipId', isEqualTo: internshipId)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Delete an internship
  Future<void> deleteInternship(String internshipId) async {
    await _firestore.collection('internships').doc(internshipId).delete();
  }

  // Toggle active/inactive
  Future<void> toggleInternshipStatus(String internshipId, bool isActive) async {
    await _firestore
        .collection('internships')
        .doc(internshipId)
        .update({'isActive': isActive});
  }
  // Update application status (accept/reject)
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _firestore
        .collection('applications')
        .doc(applicationId)
        .update({'status': status});
  }

// Get ALL applications for ALL internships by an employer
  Stream<List<ApplicationModel>> getEmployerApplications(String employerId) {
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}