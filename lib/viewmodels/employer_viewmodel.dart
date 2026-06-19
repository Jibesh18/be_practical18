import 'package:flutter/material.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';
import '../services/internship_service.dart';

class EmployerViewModel extends ChangeNotifier {
  final InternshipService _service = InternshipService();

  // ── Streams ────────────────────────────────────────────────────────
  Stream<List<InternshipModel>> getMyListings(String employerId) =>
      _service.getEmployerInternships(employerId);

  Stream<List<ApplicationModel>> getApplicantsForInternship(String internshipId) =>
      _service.getApplicants(internshipId);

  Stream<List<ApplicationModel>> getAllMyApplicants(String employerId) =>
      _service.getEmployerApplications(employerId);

  // ── Post internship ────────────────────────────────────────────────
  bool _isPosting = false;
  String? _postError;
  bool _postSuccess = false;

  bool get isPosting => _isPosting;
  String? get postError => _postError;
  bool get postSuccess => _postSuccess;

  void resetPostState() {
    _postError = null;
    _postSuccess = false;
    notifyListeners();
  }

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
    _postSuccess = false;
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
      _postSuccess = true;
      return true;
    } catch (e) {
      _postError = 'Failed to post internship. Please try again.';
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  // ── Manage listings ────────────────────────────────────────────────
  Future<void> toggleStatus(String internshipId, bool currentStatus) async {
    await _service.toggleInternshipStatus(internshipId, !currentStatus);
  }

  Future<void> deleteInternship(String internshipId) async {
    await _service.deleteInternship(internshipId);
  }

  // ── Manage applicants ──────────────────────────────────────────────
  Future<void> acceptApplicant(String applicationId) async {
    await _service.updateApplicationStatus(applicationId, 'accepted');
  }

  Future<void> rejectApplicant(String applicationId) async {
    await _service.updateApplicationStatus(applicationId, 'rejected');
  }
}