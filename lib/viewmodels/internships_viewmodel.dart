import 'package:flutter/material.dart';
import '../models/internship.dart';

class InternshipsViewModel extends ChangeNotifier {
  final List<Internship> _internships = [
    Internship(title: 'Data Analyst Intern', company: 'ABC Tech', location: 'Kathmandu', stipend: 'Paid • 15k'),
    Internship(title: 'Flutter Developer Intern', company: 'TechNepal', location: 'Remote', stipend: 'Paid • 12k'),
    Internship(title: 'Digital Marketing Intern', company: 'GrowthHub', location: 'Kathmandu', stipend: 'Unpaid'),
  ];

  List<Internship> get internships => _internships;

  // Add search logic if needed later
}