import 'package:flutter/material.dart';
import '../models/application_model.dart';   // Make sure this matches your model

class ApplicationsViewModel extends ChangeNotifier {
  final List<Application> _applications = [
    Application(
      title: 'Data Analyst Intern',
      company: 'ABC Tech',
      status: 'Under Review',
      date: 'Applied 2 days ago',
      color: Colors.orange,
    ),
    Application(
      title: 'Flutter Developer Intern',
      company: 'TechNepal',
      status: 'Interview Scheduled',
      date: 'Applied 1 week ago',
      color: Colors.blue,
    ),
    Application(
      title: 'Digital Marketing Intern',
      company: 'GrowthHub',
      status: 'Rejected',
      date: 'Applied 3 weeks ago',
      color: Colors.red,
    ),
  ];

  List<Application> _filteredApplications = [];
  String _searchQuery = '';

  ApplicationsViewModel() {
    _filteredApplications = _applications;
  }

  List<Application> get applications => _filteredApplications;

  void searchApplications(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredApplications = _applications;
    } else {
      _filteredApplications = _applications
          .where((application) =>
              application.title.toLowerCase().contains(query.toLowerCase()) ||
              application.company.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Apply for new internship (Called from InternshipsScreen)
  void applyForInternship({
    required String title,
    required String company,
  }) {
    final newApplication = Application(
      title: title,
      company: company,
      status: 'Pending',
      date: 'Applied just now',
      color: Colors.blue,
    );

    _applications.insert(0, newApplication); // Add at the top
    searchApplications(_searchQuery); // Refresh filtered list
    notifyListeners();
  }

  /// Optional: Update status of an application
  void updateStatus(int index, String newStatus, Color newColor) {
    if (index >= 0 && index < _applications.length) {
      _applications[index].status = newStatus;
      _applications[index].color = newColor;
      _applications[index].date = 'Updated just now';
      notifyListeners();
    }
  }
}