import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../models/internship_model.dart';
import '../services/internship_service.dart';

class EmployerViewModel extends ChangeNotifier {
  final InternshipService _service = InternshipService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Current user helpers ────────────────────────────────────────────────
  String? get currentEmployerId => _auth.currentUser?.uid;
  String? get currentEmployerName => _auth.currentUser?.displayName;

  // ── Streams ──────────────────────────────────────────────────────────────
  Stream<List<InternshipModel>> getMyListings(String employerId) =>
      _service.getEmployerInternships(employerId);

  // FIXED: now requires employerId — matches the Firestore security rule
  // which checks resource.data.employerId == request.auth.uid. Without
  // this filter in the query itself, Firestore rejects it with
  // PERMISSION_DENIED even though the rule "looks" like it should pass.
  Stream<List<ApplicationModel>> getApplicantsForInternship(
      String internshipId, String employerId) =>
      _service.getApplicants(internshipId, employerId);

  Stream<List<ApplicationModel>> getAllMyApplicants(String employerId) =>
      _service.getEmployerApplications(employerId);

  // ── Stat helpers ─────────────────────────────────────────────────────────
  int getActiveListingCount(List<InternshipModel> listings) =>
      listings.where((l) => l.isActive).length;

  int getPausedListingCount(List<InternshipModel> listings) =>
      listings.where((l) => !l.isActive).length;

  int getPendingCount(List<ApplicationModel> apps) =>
      apps.where((a) => a.status == 'pending').length;

  int getAcceptedCount(List<ApplicationModel> apps) =>
      apps.where((a) => a.status == 'accepted').length;

  int getRejectedCount(List<ApplicationModel> apps) =>
      apps.where((a) => a.status == 'rejected').length;

  List<ApplicationModel> getRecentApplications(List<ApplicationModel> apps, {int limit = 5}) =>
      apps.take(limit).toList();

  // ── Application status label ────────────────────────────────────────────
  String getStatusLabel(String status) {
    switch (status) {
      case 'accepted':    return 'Accepted';
      case 'rejected':    return 'Rejected';
      case 'shortlisted': return 'Shortlisted';
      case 'reviewed':    return 'Reviewed';
      default:            return 'Pending';
    }
  }

  // ── Post internship ──────────────────────────────────────────────────────
  bool _isPosting = false;
  String? _postError;

  bool get isPosting => _isPosting;
  String? get postError => _postError;

  Future<bool> postInternship({
    required String title,
    required String company,
    required String location,
    required String type,
    required String duration,
    required String stipend,
    required String description,
    required String requirements,
    required List<String> skills,
    required String postedBy,
    required String employerName,
  }) async {
    _isPosting = true;
    _postError = null;
    notifyListeners();
    try {
      final internship = InternshipModel(
        id: '',
        title: title.trim(),
        company: company.trim(),
        location: location.trim(),
        type: type,
        duration: duration.trim(),
        stipend: stipend.trim(),
        description: description.trim(),
        requirements: requirements.trim(),
        skills: skills,
        postedBy: postedBy,
        employerName: employerName,
        postedAt: DateTime.now(),
        isActive: true,
      );
      await _service.postInternship(internship);
      return true;
    } catch (e) {
      _postError = 'Failed to post internship. Please try again.';
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  // ── Update internship ────────────────────────────────────────────────────
  bool _isUpdating = false;
  String? _updateError;

  bool get isUpdating => _isUpdating;
  String? get updateError => _updateError;

  Future<bool> updateInternship({
    required String id,
    required String title,
    required String company,
    required String location,
    required String type,
    required String duration,
    required String stipend,
    required String description,
    required String requirements,
    required List<String> skills,
    required bool isActive,
    required String postedBy,
    required String employerName,
    required DateTime postedAt,
  }) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();
    try {
      final internship = InternshipModel(
        id: id,
        title: title.trim(),
        company: company.trim(),
        location: location.trim(),
        type: type,
        duration: duration.trim(),
        stipend: stipend.trim(),
        description: description.trim(),
        requirements: requirements.trim(),
        skills: skills,
        postedBy: postedBy,
        employerName: employerName,
        postedAt: postedAt,
        isActive: isActive,
      );
      await _service.updateInternship(internship);
      return true;
    } catch (e) {
      _updateError = 'Failed to update internship. Please try again.';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ── Toggle / End / Delete ────────────────────────────────────────────────
  Future<void> toggleStatus(String internshipId, bool currentStatus) =>
      _service.toggleInternshipStatus(internshipId, !currentStatus);

  // NEW: Permanently end an internship — cannot be undone or reopened.
  Future<void> endInternship(String internshipId) =>
      _service.endInternship(internshipId);

  Future<void> deleteInternship(String internshipId) =>
      _service.deleteInternship(internshipId);

  // ── Manage applicants ────────────────────────────────────────────────────
  Future<void> acceptApplicant(String applicationId) =>
      _service.updateApplicationStatus(applicationId, 'accepted');

  Future<void> rejectApplicant(String applicationId) =>
      _service.updateApplicationStatus(applicationId, 'rejected');

  Future<void> markAsReviewed(String applicationId) =>
      _service.updateApplicationStatus(applicationId, 'reviewed');

  Future<void> shortlistApplicant(String applicationId) =>
      _service.updateApplicationStatus(applicationId, 'shortlisted');
}