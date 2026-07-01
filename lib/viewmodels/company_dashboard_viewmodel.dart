import 'package:flutter/material.dart';
import '../models/internship_model.dart';

class CompanyDashboardViewModel extends ChangeNotifier {
  int totalInternships = 8;
  int activeApplications = 34;
  int shortlisted = 12;

  List<Internship> recentInternships = [
    Internship(
      id: '1',
      title: 'Flutter Developer Intern',
      company: 'Your Company',
      location: 'Kathmandu',
      stipend: '15,000',
      type: 'Remote',
      skills: ['Flutter', 'Dart', 'Firebase'],
      description: 'Looking for passionate Flutter developers...',
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      applicationsCount: 18,
    ),
  ];

  void refreshDashboard() {
    notifyListeners();
  }
}