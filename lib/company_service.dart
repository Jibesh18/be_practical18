import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../model/internship.dart';
import '../model/application.dart';
import '../model/company_profile.dart';
import '../model/interview.dart';

class CompanyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // --- Company Profile ---
  Stream<CompanyProfile?> streamCompanyProfile() {
    if (_uid.isEmpty) return Stream.value(null);
    return _db.collection('companies').doc(_uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CompanyProfile.fromFirestore(doc);
    });
  }

  Future<void> updateCompanyProfile(CompanyProfile profile) async {
    await _db.collection('companies').doc(_uid).set(profile.toFirestore(), SetOptions(merge: true));
  }

  // --- Internships Management ---
  Stream<List<Internship>> streamMyInternships() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db
        .collection('internships')
        .where('companyId', isEqualTo: _uid)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList());
  }

  Future<void> postInternship(Internship internship) async {
    final docRef = _db.collection('internships').doc();
    final data = internship.toFirestore();
    data['companyId'] = _uid;
    data['id'] = docRef.id;
    data['postedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
  }

  Future<void> duplicateInternship(String id) async {
    final doc = await _db.collection('internships').doc(id).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    data['title'] = "${data['title']} (Copy)";
    data['status'] = InternshipStatus.draft.toString();
    data['postedAt'] = FieldValue.serverTimestamp();
    data['applicantCount'] = 0;
    await _db.collection('internships').add(data);
  }

  Future<void> updateInternshipStatus(String id, InternshipStatus status) async {
    await _db.collection('internships').doc(id).update({'status': status.toString()});
  }

  Future<void> deleteInternship(String id) async {
    await _db.collection('internships').doc(id).delete();
  }

  // --- Applications ---
  Stream<List<Application>> streamApplications({String? internshipId}) {
    if (_uid.isEmpty) return Stream.value([]);
    Query query = _db.collection('applications').where('companyId', isEqualTo: _uid);
    if (internshipId != null) query = query.where('internshipId', isEqualTo: internshipId);
    return query.orderBy('appliedAt', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Application.fromFirestore(doc)).toList());
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    final appDoc = await _db.collection('applications').doc(applicationId).get();
    if (!appDoc.exists) return;
    
    final data = appDoc.data() as Map<String, dynamic>;
    final studentId = data['studentId'];
    final internshipId = data['internshipId'];

    final batch = _db.batch();
    batch.update(_db.collection('applications').doc(applicationId), {'status': status.toString()});
    batch.update(
      _db.collection('users').doc(studentId).collection('my_applications').doc(internshipId), 
      {'status': status.toString()}
    );
    await batch.commit();
  }

  // --- Interview Actions ---
  Stream<List<Interview>> streamInterviews() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db
        .collection('interviews')
        .where('companyId', isEqualTo: _uid)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Interview.fromFirestore(doc)).toList());
  }

  Future<void> scheduleInterview(Interview interview) async {
    await _db.collection('interviews').doc().set(interview.toFirestore());
    final apps = await _db.collection('applications')
        .where('studentId', isEqualTo: interview.studentId)
        .where('internshipId', isEqualTo: interview.internshipId)
        .get();
        
    if (apps.docs.isNotEmpty) {
      await updateApplicationStatus(apps.docs.first.id, ApplicationStatus.interviewScheduled);
    }
  }

  Future<void> cancelInterview(String id, String studentId, String title) async {
    await _db.collection('interviews').doc(id).delete();
  }

  Future<void> completeInterview(String id) async {
    await _db.collection('interviews').doc(id).update({'isCompleted': true});
  }

  // --- Analytics Engine ---
  Stream<Map<String, dynamic>> streamAnalytics() {
    if (_uid.isEmpty) return Stream.value({});
    return _db.collection('applications')
        .where('companyId', isEqualTo: _uid)
        .snapshots()
        .map((appSnap) {
      final apps = appSnap.docs;
      final total = apps.length;
      
      final collegeMap = <String, int>{};
      final skillMap = <String, int>{};
      
      for (var doc in apps) {
        final data = doc.data() as Map<String, dynamic>;
        final college = data['studentCollege'] as String? ?? 'Other';
        collegeMap[college] = (collegeMap[college] ?? 0) + 1;
        
        final skills = List<String>.from(data['studentSkills'] ?? []);
        for (var s in skills) {
          skillMap[s] = (skillMap[s] ?? 0) + 1;
        }
      }

      final sortedColleges = collegeMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final sortedSkills = skillMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      final hiredCount = apps.where((d) {
        final data = d.data() as Map<String, dynamic>;
        return data['status'] == ApplicationStatus.hired.toString() || data['status'] == ApplicationStatus.selected.toString();
      }).length;

      final shortlistedCount = apps.where((d) => (d.data() as Map<String, dynamic>)['status'] == ApplicationStatus.shortlisted.toString()).length;

      // Calculate Daily Application Trend
      final now = DateTime.now();
      final dailyTrend = <DateTime, int>{};
      for (int i = 0; i < 7; i++) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final count = apps.where((d) {
          final date = ((d.data() as Map<String, dynamic>)['appliedAt'] as Timestamp?)?.toDate();
          return date != null && date.year == day.year && date.month == day.month && date.day == day.day;
        }).length;
        dailyTrend[day] = count;
      }

      return {
        'totalApplications': total,
        'hiringRate': total > 0 ? (hiredCount / total) * 100 : 0.0,
        'topColleges': sortedColleges.take(5).map((e) => {'name': e.key, 'count': e.value}).toList(),
        'topSkills': sortedSkills.take(5).map((e) => {'name': e.key, 'count': e.value}).toList(),
        'hiredCount': hiredCount,
        'shortlistedCount': shortlistedCount,
        'dailyTrend': dailyTrend,
        'conversionRate': total > 0 ? (shortlistedCount / total) * 100 : 0.0,
      };
    });
  }

  Stream<Map<String, dynamic>> streamDashboardStats() {
    if (_uid.isEmpty) return Stream.value({});

    final appsStream = _db.collection('applications').where('companyId', isEqualTo: _uid).snapshots();
    final internshipsStream = _db.collection('internships').where('companyId', isEqualTo: _uid).snapshots();
    final profileStream = _db.collection('companies').doc(_uid).snapshots();

    return Rx.combineLatest3(
      appsStream,
      internshipsStream,
      profileStream,
      (QuerySnapshot appSnap, QuerySnapshot internshipsSnap, DocumentSnapshot profileDoc) {
        final apps = appSnap.docs;
        final internships = internshipsSnap.docs;
        final today = DateTime.now();
        final startOfToday = DateTime(today.year, today.month, today.day);

        return {
          'activeInternships': internships.where((d) => (d.data() as Map<String, dynamic>)['status'] == InternshipStatus.active.toString()).length,
          'draftInternships': internships.where((d) => (d.data() as Map<String, dynamic>)['status'] == InternshipStatus.draft.toString()).length,
          'closedInternships': internships.where((d) => (d.data() as Map<String, dynamic>)['status'] == InternshipStatus.closed.toString()).length,
          'totalApplicants': apps.length,
          'newApplicantsToday': apps.where((d) {
            final t = (d.data() as Map<String, dynamic>)['appliedAt'] as Timestamp?;
            return t != null && t.toDate().isAfter(startOfToday);
          }).length,
          'interviewsScheduled': apps.where((d) => (d.data() as Map<String, dynamic>)['status'] == ApplicationStatus.interviewScheduled.toString()).length,
          'shortlisted': apps.where((d) => (d.data() as Map<String, dynamic>)['status'] == ApplicationStatus.shortlisted.toString()).length,
          'hired': apps.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['status'] == ApplicationStatus.hired.toString() || data['status'] == ApplicationStatus.selected.toString();
          }).length,
          'profileCompletion': _calculateProfileCompletion(profileDoc),
          'membership': profileDoc.exists ? (profileDoc.data() as Map<String, dynamic>)['membershipPlan'] ?? 'Free' : 'Free',
        };
      }
    );
  }

  int _calculateProfileCompletion(DocumentSnapshot doc) {
    if (!doc.exists) return 0;
    final d = doc.data() as Map<String, dynamic>;
    int score = 0;
    if (d['name'] != null && d['name'].toString().isNotEmpty) score += 20;
    if (d['logo'] != null && d['logo'].toString().isNotEmpty) score += 20;
    if (d['description'] != null && d['description'].toString().isNotEmpty) score += 20;
    if (d['website'] != null && d['website'].toString().isNotEmpty) score += 20;
    if (d['industry'] != null && d['industry'].toString().isNotEmpty) score += 20;
    return score;
  }
}

