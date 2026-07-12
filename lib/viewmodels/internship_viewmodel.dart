import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../models/internship_model.dart';
import '../models/user_model.dart';
import '../services/ai_services.dart';
import '../services/internship_service.dart';

class InternshipViewModel extends ChangeNotifier {
  final InternshipService _service = InternshipService();

  // ── Streams ───────────────────────────────────────────────────────────────
  Stream<List<InternshipModel>> get allInternships =>
      _service.getAllInternships();

  Stream<List<InternshipModel>> getEmployerInternships(String uid) =>
      _service.getEmployerInternships(uid);

  Stream<List<ApplicationModel>> getMyApplications(String uid) =>
      _service.getMyApplications(uid);

  // ── Filter state ──────────────────────────────────────────────────────────
  String _searchQuery = '';
  String _selectedType = 'All';
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

  // ── Filtering logic lives in ViewModel ────────────────────────────────────
  List<InternshipModel> applyFilters(List<InternshipModel> all) {
    return all.where((i) {
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty ||
          i.title.toLowerCase().contains(q) ||
          i.company.toLowerCase().contains(q) ||
          i.skills.any((s) => s.toLowerCase().contains(q));

      final matchesType = _selectedType == 'All' || i.type == _selectedType;

      final matchesLocation = _selectedLocation == 'All' ||
          i.location.toLowerCase().contains(_selectedLocation.toLowerCase());

      return matchesQuery && matchesType && matchesLocation;
    }).toList();
  }

  // ── Apply action ──────────────────────────────────────────────────────────
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
    } catch (_) {
      _applyError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }

  Future<bool> hasApplied(String internshipId, String userId) =>
      _service.hasApplied(internshipId, userId);

  // ── AI internship suggestions (for intern seekers) ─────────────────────────
  // Mirrors EmployerViewModel's getAISuggestion, but reversed: instead of
  // matching applicants against one listing, this matches one candidate's
  // profile (bio/education/experience/skills — all plain text UserModel
  // fields) against the list of currently open internships.
  String? _aiSuggestionResult;
  bool _aiSuggestionLoading = false;
  String? _aiSuggestionError;

  String? get aiSuggestionResult => _aiSuggestionResult;
  bool get isAiSuggestionLoading => _aiSuggestionLoading;
  String? get aiSuggestionError => _aiSuggestionError;

  Future<void> getAISuggestionsForUser({
    required UserModel user,
    required List<InternshipModel> internships,
  }) async {
    if (_aiSuggestionLoading) return;

    _aiSuggestionLoading = true;
    _aiSuggestionError = null;
    notifyListeners();

    try {
      final profileSummary = '''
Name: ${user.name}
Bio: ${user.bio.isNotEmpty ? user.bio : 'Not provided'}
Education: ${user.education.isNotEmpty ? user.education : 'Not provided'}
Experience: ${user.experience.isNotEmpty ? user.experience : 'Not provided'}
Skills: ${user.skills.isNotEmpty ? user.skills.join(', ') : 'Not provided'}
''';

      final listingsText = internships.take(25).map((i) =>
      '- "${i.title}" at ${i.company} (${i.type}, ${i.location}) | '
          'Required skills: ${i.skills.join(', ')} | '
          'Duration: ${i.duration} | Stipend: ${i.stipend}'
      ).join('\n');

      final prompt = '''
You are a career advisor helping a student/early-career candidate find internships that fit them.

Candidate profile:
$profileSummary

Currently open internships:
${listingsText.isEmpty ? 'No internships are currently open.' : listingsText}

Based on the candidate's education, experience, and skills, provide:
1. A one-line read on their current level (beginner / intermediate / advanced) based on what's in their profile.
2. The top 3 internships from the list above that best match them, each with a one-line reason why. If fewer than 3 are a real fit, only list the genuine matches — don't force weak ones. If the list is empty, say so plainly.
3. 2-3 specific skills they could learn next to become a stronger candidate for internships in their field.
4. One concrete tip to improve their profile or application.

Keep it concise, encouraging, and practical for someone early in their career. Use clear short sections, not long paragraphs.
''';

      const systemPrompt =
          'You are a friendly, practical career advisor for students and '
          'early-career internship seekers. Be concise, encouraging, and '
          'specific — avoid generic advice.';

      final response = await AIService.ask(
        prompt: prompt,
        systemPrompt: systemPrompt,
        maxOutputTokens: 800,
      );

      _aiSuggestionResult = response;
    } catch (e) {
      _aiSuggestionError = 'Could not get AI suggestions. Please try again.';
    } finally {
      _aiSuggestionLoading = false;
      notifyListeners();
    }
  }
}