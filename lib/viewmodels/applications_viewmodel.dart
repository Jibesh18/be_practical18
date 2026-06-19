import 'package:flutter/material.dart';

import '../models/application_model.dart';

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
      title: 'Flutter Developer',
      company: 'TechNepal',
      status: 'Interview Scheduled',
      date: 'Applied 1 week ago',
      color: Colors.blue,
    ),
    Application(
      title: 'Marketing Intern',
      company: 'GrowthHub',
      status: 'Rejected',
      date: 'Applied 3 weeks ago',
      color: Colors.red,
    ),
  ];

  List<Application> get applications => _applications;
}