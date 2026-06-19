import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String internshipId;
  final String internshipTitle;
  final String company;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String employerId;
  final String status;
  final DateTime appliedAt;

  ApplicationModel({
    required this.id,
    required this.internshipId,
    required this.internshipTitle,
    required this.company,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.employerId,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      internshipId: map['internshipId'] ?? '',
      internshipTitle: map['internshipTitle'] ?? '',
      company: map['company'] ?? '',
      applicantId: map['applicantId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      applicantEmail: map['applicantEmail'] ?? '',
      employerId: map['employerId'] ?? '',   // ← ADD THIS
      status: map['status'] ?? 'pending',
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'internshipId': internshipId,
      'internshipTitle': internshipTitle,
      'company': company,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'employerId': employerId,
      'status': status,
      'appliedAt': FieldValue.serverTimestamp(),
    };
  }
}