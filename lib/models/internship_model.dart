import 'package:cloud_firestore/cloud_firestore.dart';

class InternshipModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;        // 'Remote', 'On-site', 'Hybrid'
  final String duration;    // e.g. '3 months'
  final String stipend;     // e.g. '5000/month' or 'Unpaid'
  final String description;
  final String requirements;
  final List<String> skills; // e.g. ['Flutter', 'Firebase']
  final String postedBy;    // employer uid
  final String employerName;
  final DateTime postedAt;
  final bool isActive;

  InternshipModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.duration,
    required this.stipend,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.postedBy,
    required this.employerName,
    required this.postedAt,
    required this.isActive,
  });

  // Firestore → Model
  factory InternshipModel.fromMap(Map<String, dynamic> map, String id) {
    return InternshipModel(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? 'Remote',
      duration: map['duration'] ?? '',
      stipend: map['stipend'] ?? 'Unpaid',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      postedBy: map['postedBy'] ?? '',
      employerName: map['employerName'] ?? '',
      postedAt: (map['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'duration': duration,
      'stipend': stipend,
      'description': description,
      'requirements': requirements,
      'skills': skills,
      'postedBy': postedBy,
      'employerName': employerName,
      'postedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }
}