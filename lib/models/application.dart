import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  applied,
  viewed,
  shortlisted,
  interviewScheduled,
  selected,
  rejected,
  hired
}

class Application {
  final String id;
  final String studentId;
  final String studentName;
  final String studentAvatar;
  final String studentCollege;
  final String studentDegree;
  final List<String> studentSkills;
  final String internshipId;
  final String internshipTitle;
  final String companyId;
  final String resumeUrl;
  final String coverLetter;
  final String portfolioUrl;
  final String githubUrl;
  final String linkedinUrl;
  final DateTime appliedAt;
  final ApplicationStatus status;

  Application({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentAvatar,
    required this.studentCollege,
    required this.studentDegree,
    required this.studentSkills,
    required this.internshipId,
    required this.internshipTitle,
    required this.companyId,
    required this.resumeUrl,
    required this.coverLetter,
    this.portfolioUrl = '',
    this.githubUrl = '',
    this.linkedinUrl = '',
    required this.appliedAt,
    required this.status,
  });

  factory Application.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentAvatar: data['studentAvatar'] ?? '',
      studentCollege: data['studentCollege'] ?? '',
      studentDegree: data['studentDegree'] ?? '',
      studentSkills: List<String>.from(data['studentSkills'] ?? []),
      internshipId: data['internshipId'] ?? '',
      internshipTitle: data['internshipTitle'] ?? '',
      companyId: data['companyId'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      coverLetter: data['coverLetter'] ?? '',
      portfolioUrl: data['portfolioUrl'] ?? '',
      githubUrl: data['githubUrl'] ?? '',
      linkedinUrl: data['linkedinUrl'] ?? '',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => ApplicationStatus.applied,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentAvatar': studentAvatar,
      'studentCollege': studentCollege,
      'studentDegree': studentDegree,
      'studentSkills': studentSkills,
      'internshipId': internshipId,
      'internshipTitle': internshipTitle,
      'companyId': companyId,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'portfolioUrl': portfolioUrl,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'status': status.toString(),
    };
  }
}

