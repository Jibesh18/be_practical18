import 'package:flutter/material.dart';
import '../models/internship_model.dart';

class InternshipsViewModel extends ChangeNotifier {
  final List<Internship> _internships = [
    Internship(
      id: '1',
      title: 'Data Analyst Intern',
      company: 'ABC Tech',
      location: 'Kathmandu',
      stipend: '15,000',
      type: 'Full-time',
      skills: ['Python', 'SQL', 'Power BI'],
      description: 'Looking for a passionate data analyst intern...',
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      applicationsCount: 24,
    ),
    Internship(
      id: '2',
      title: 'Flutter Developer Intern',
      company: 'TechNepal',
      location: 'Remote',
      stipend: '12,000',
      type: 'Internship',
      skills: ['Flutter', 'Dart', 'Firebase'],
      description: 'Join our mobile development team...',
      postedDate: DateTime.now().subtract(const Duration(days: 5)),
      applicationsCount: 41,
    ),
    Internship(
      id: '3',
      title: 'Digital Marketing Intern',
      company: 'GrowthHub',
      location: 'Kathmandu',
      stipend: '8,000',
      type: 'Part-time',
      skills: ['Social Media', 'Content Writing', 'SEO'],
      description: 'Help us grow our online presence...',
      postedDate: DateTime.now().subtract(const Duration(days: 7)),
      applicationsCount: 15,
    ),
  ];

  List<Internship> _filteredInternships = [];
  String _searchQuery = '';

  InternshipsViewModel() {
    _filteredInternships = _internships;
  }

  List<Internship> get internships => _filteredInternships;

  void searchInternships(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredInternships = _internships;
    } else {
      _filteredInternships = _internships
          .where((internship) =>
              internship.title.toLowerCase().contains(query.toLowerCase()) ||
              internship.company.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}