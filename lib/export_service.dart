import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../model/application.dart';
import '../model/interview.dart';

class ExportService {
  Future<String?> exportApplicantsToCSV(List<Application> apps) async {
    try {
      String csv = 'Student Name,College,Degree,Internship,Status,Applied Date\n';
      
      for (var app in apps) {
        csv += '${app.studentName},${app.studentCollege},${app.studentDegree},${app.internshipTitle},${app.status.name},${app.appliedAt}\n';
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/applicants_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      
      debugPrint("Exported to: ${file.path}");
      return file.path;
    } catch (e) {
      debugPrint("Export error: $e");
      return null;
    }
  }

  Future<String?> exportInterviewsToCSV(List<Interview> interviews) async {
    try {
      String csv = 'Student Name,Internship,Date,Time,Mode,Meeting Link\n';
      
      for (var i in interviews) {
        csv += '${i.studentName},${i.internshipTitle},${i.dateTime},${i.mode.name},${i.meetingLink}\n';
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/interviews_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      
      return file.path;
    } catch (e) {
      return null;
    }
  }
}

