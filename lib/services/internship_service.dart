import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';
import 'package:flutter/foundation.dart';

class InternshipService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ── Internships ──────────────────────────────────────────────────────────

  Future<void> postInternship(InternshipModel internship) async {
    await firestore.collection('internships').add(internship.toMap());
  }

  Future<void> updateInternship(InternshipModel internship) async {
    await firestore.collection('internships').doc(internship.id).update({
      'title': internship.title,
      'company': internship.company,
      'location': internship.location,
      'type': internship.type,
      'duration': internship.duration,
      'stipend': internship.stipend,
      'description': internship.description,
      'requirements': internship.requirements,
      'skills': internship.skills,
      'isActive': internship.isActive,
    });
  }

  Future<void> toggleInternshipStatus(
      String internshipId, bool isActive) async {
    await firestore
        .collection('internships')
        .doc(internshipId)
        .update({
      'isActive': isActive,
      'status': isActive ? 'active' : 'paused',
    });
  }

  // FIXED: Batch delete — also closes undecided applications so interns
  // see "Position Closed" instead of being stuck on "Pending" forever.
  Future<void> deleteInternship(String internshipId) async {
    final batch = firestore.batch();
    batch.delete(firestore.collection('internships').doc(internshipId));

    final appsSnap = await firestore
        .collection('applications')
        .where('internshipId', isEqualTo: internshipId)
        .where('status', whereIn: ['pending', 'reviewed'])
        .get();
    for (final doc in appsSnap.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }
    await batch.commit();
  }

  Future<void> endInternship(String internshipId, String employerId) async {
    await firestore.collection('internships').doc(internshipId).update({
      'isActive': false,
      'status': 'ended',
    });

    try {
      final appsSnap = await firestore
          .collection('applications')
          .where('internshipId', isEqualTo: internshipId)
          .where('employerId', isEqualTo: employerId)
          .where('status', whereIn: ['pending', 'reviewed'])
          .get();

      if (appsSnap.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in appsSnap.docs) {
          batch.update(doc.reference, {'status': 'closed'});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('endInternship: could not auto-close pending applications for $internshipId: $e');
    }
  }

  Stream<List<InternshipModel>> getAllInternships() {
    return firestore
        .collection('internships')
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => InternshipModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<InternshipModel>> getEmployerInternships(String employerId) {
    return firestore
        .collection('internships')
        .where('postedBy', isEqualTo: employerId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => InternshipModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // ── Applications ─────────────────────────────────────────────────────────

  Future<void> applyToInternship(ApplicationModel application) async {
    await firestore.collection('applications').add(application.toMap());
  }

  Future<bool> hasApplied(String internshipId, String userId) async {
    final snap = await firestore
        .collection('applications')
        .where('internshipId', isEqualTo: internshipId)
        .where('applicantId', isEqualTo: userId)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Applications submitted BY an intern (for their "My Applications" screen)
  Stream<List<ApplicationModel>> getMyApplications(String userId) {
    return firestore
        .collection('applications')
        .where('applicantId', isEqualTo: userId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// All applicants for a specific internship (employer view).
  // FIXED: now requires employerId too, and filters by BOTH internshipId
  // AND employerId in the same query. This matches the Firestore security
  // rule (which checks resource.data.employerId == request.auth.uid) so
  // the query can actually be validated and won't get PERMISSION_DENIED.
  Stream<List<ApplicationModel>> getApplicants(
      String internshipId, String employerId) {
    return firestore
        .collection('applications')
        .where('internshipId', isEqualTo: internshipId)
        .where('employerId', isEqualTo: employerId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// All applications across all internships posted by an employer
  Stream<List<ApplicationModel>> getEmployerApplications(String employerId) {
    return firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    await firestore
        .collection('applications')
        .doc(applicationId)
        .update({'status': status});
  }
}