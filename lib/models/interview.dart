import 'package:cloud_firestore/cloud_firestore.dart';

enum InterviewMode { online, offline }

class Interview {
  final String id;
  final String studentId;
  final String studentName;
  final String internshipId;
  final String internshipTitle;
  final String companyId;
  final DateTime dateTime;
  final InterviewMode mode;
  final String meetingLink;
  final String location;
  final String notes;
  final bool isCompleted;
  final bool isCancelled;

  Interview({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.internshipId,
    required this.internshipTitle,
    required this.companyId,
    required this.dateTime,
    required this.mode,
    this.meetingLink = '',
    this.location = '',
    this.notes = '',
    this.isCompleted = false,
    this.isCancelled = false,
  });

  factory Interview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Interview(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      internshipId: data['internshipId'] ?? '',
      internshipTitle: data['internshipTitle'] ?? '',
      companyId: data['companyId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      mode: InterviewMode.values.firstWhere(
        (e) => e.toString() == data['mode'],
        orElse: () => InterviewMode.online,
      ),
      meetingLink: data['meetingLink'] ?? '',
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      isCancelled: data['isCancelled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'internshipId': internshipId,
      'internshipTitle': internshipTitle,
      'companyId': companyId,
      'dateTime': Timestamp.fromDate(dateTime),
      'mode': mode.toString(),
      'meetingLink': meetingLink,
      'location': location,
      'notes': notes,
      'isCompleted': isCompleted,
      'isCancelled': isCancelled,
    };
  }
}

