import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/application_model.dart';
import '../services/internship_service.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final InternshipService _service = InternshipService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<ApplicationModel>> getMyApplications(String userId) =>
      _service.getMyApplications(userId);

  // FIXED: Added 'closed' status — shown when employer deletes or ends
  // the internship without making a decision on the application.
  String getStatusLabel(String status) {
    switch (status) {
      case 'accepted':    return 'Accepted ✓';
      case 'rejected':    return 'Not Selected';
      case 'shortlisted': return 'Shortlisted';
      case 'reviewed':    return 'Under Review';
      case 'closed':      return 'Position Closed';
      default:            return 'Pending';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':    return const Color(0xFF22C55E);
      case 'rejected':    return const Color(0xFFEF4444);
      case 'shortlisted': return const Color(0xFF3B82F6);
      case 'reviewed':    return const Color(0xFF06B6D4);
      case 'closed':      return const Color(0xFF94A3B8); // grey — neutral
      default:            return const Color(0xFFF59E0B); // amber — pending
    }
  }
}