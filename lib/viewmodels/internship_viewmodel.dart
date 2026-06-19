import 'package:flutter/material.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';
import '../services/internship_service.dart';

class InternshipViewModel extends ChangeNotifier {
  final InternshipService _service = InternshipService();

  // ── Streams exposed to UI ──────────────────────────────────────────
  Stream<List<InternshipModel>> get allInternships =>
      _service.getAllInternships();

  Stream<List<InternshipModel>> getEmployerInternships(String uid) =>
      _service.getEmployerInternships(uid);

  Stream<List<ApplicationModel>> getMyApplications(String uid) =>
      _service.getMyApplications(uid);

  // ── Filter state ───────────────────────────────────────────────────
  String _searchQuery = '';
  String _selectedType = 'All'; // 'All', 'Remote', 'On-site', 'Hybrid'
  String _selectedLocation = 'All';

  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String get selectedLocation => _selectedLocation;

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = 'All';
    _selectedLocation = 'All';
    notifyListeners();
  }

  // ── Client-side filtering ──────────────────────────────────────────
  List<InternshipModel> applyFilters(List<InternshipModel> all) {
    return all.where((i) {
      final matchesQuery = _searchQuery.isEmpty ||
          i.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.skills.any((s) =>
              s.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesType =
          _selectedType == 'All' || i.type == _selectedType;

      final matchesLocation = _selectedLocation == 'All' ||
          i.location
              .toLowerCase()
              .contains(_selectedLocation.toLowerCase());

      return matchesQuery && matchesType && matchesLocation;
    }).toList();
  }

  // ── Apply action ───────────────────────────────────────────────────
  bool _isApplying = false;
  String? _applyError;

  bool get isApplying => _isApplying;
  String? get applyError => _applyError;

  Future<bool> apply({
    required InternshipModel internship,
    required String applicantId,
    required String applicantName,
    required String applicantEmail,
  }) async {
    _isApplying = true;
    _applyError = null;
    notifyListeners();

    try {
      final alreadyApplied =
      await _service.hasApplied(internship.id, applicantId);
      if (alreadyApplied) {
        _applyError = 'You have already applied to this internship.';
        return false;
      }

      final application = ApplicationModel(
        id: '',
        internshipId: internship.id,
        internshipTitle: internship.title,
        company: internship.company,
        applicantId: applicantId,
        applicantName: applicantName,
        applicantEmail: applicantEmail,
        employerId: internship.postedBy,
        status: 'pending',
        appliedAt: DateTime.now(),
      );

      await _service.applyToInternship(application);
      return true;
    } catch (e) {
      _applyError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }

  Future<bool> hasApplied(String internshipId, String userId) =>
      _service.hasApplied(internshipId, userId);
}