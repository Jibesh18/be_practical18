import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/application.dart';
import '../model/internship.dart';
import '../model/company_profile.dart';
import '../model/interview.dart';
import '../repo/company_service.dart';
import 'auth_provider.dart';

/// Provider for the Company Service
final companyServiceProvider = Provider((ref) => CompanyService());

/// Real-time stream of the company's professional profile
final companyProfileProvider = StreamProvider<CompanyProfile?>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return Stream.value(null);
  return ref.watch(companyServiceProvider).streamCompanyProfile();
});

/// Real-time stream of internships posted by this company
final myInternshipsProvider = StreamProvider<List<Internship>>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return Stream.value([]);
  return ref.watch(companyServiceProvider).streamMyInternships();
});

/// Real-time stream of all applications received by this company
final companyApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return Stream.value([]);
  return ref.watch(companyServiceProvider).streamApplications();
});

/// Real-time stream of scheduled interviews
final interviewsProvider = StreamProvider<List<Interview>>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return Stream.value([]);
  return ref.watch(companyServiceProvider).streamInterviews();
});

/// Real-time analytical data for charts and insights
final analyticsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return Stream.value(<String, dynamic>{});
  return ref.watch(companyServiceProvider).streamAnalytics();
});

/// Aggregated statistics for the dashboard metric cards
final dashboardStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return Stream.value(<String, dynamic>{});
  return ref.watch(companyServiceProvider).streamDashboardStats();
});

/// Notifier to handle company-side actions (Write operations)
class CompanyNotifier extends StateNotifier<bool> {
  final CompanyService _service;
  CompanyNotifier(this._service) : super(false);

  /// Posts a new internship to the platform
  Future<void> postInternship(Internship internship) async {
    state = true;
    try {
      await _service.postInternship(internship);
    } finally {
      state = false;
    }
  }

  /// Duplicates an existing internship as a draft
  Future<void> duplicateInternship(String id) async {
    await _service.duplicateInternship(id);
  }

  /// Updates the hiring status of an internship (Active, Paused, Closed)
  Future<void> updateInternshipStatus(String id, InternshipStatus status) async {
    await _service.updateInternshipStatus(id, status);
  }

  /// Updates a candidate's application status and triggers student notification
  Future<void> updateApplicationStatus(String id, ApplicationStatus status) async {
    await _service.updateApplicationStatus(id, status);
  }

  /// Schedules a formal interview with a candidate
  Future<void> scheduleInterview(Interview interview) async {
    state = true;
    try {
      await _service.scheduleInterview(interview);
    } finally {
      state = false;
    }
  }

  /// Cancels a scheduled interview and notifies the student
  Future<void> cancelInterview(String id, String studentId, String title) async {
    await _service.cancelInterview(id, studentId, title);
  }

  /// Marks an interview as completed
  Future<void> completeInterview(String id) async {
    await _service.completeInterview(id);
  }

  /// Permanently deletes an internship posting
  Future<void> deleteInternship(String id) async {
    await _service.deleteInternship(id);
  }
  
  /// Updates the company's public profile data
  Future<void> updateCompanyProfile(CompanyProfile profile) async {
    state = true;
    try {
      await _service.updateCompanyProfile(profile);
    } finally {
      state = false;
    }
  }
}

/// Global provider for the Company Notifier actions
final companyNotifierProvider = StateNotifierProvider<CompanyNotifier, bool>((ref) {
  return CompanyNotifier(ref.watch(companyServiceProvider));
});
