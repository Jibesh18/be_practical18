import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../repo/export_service.dart';
import '../model/application.dart';

final exportServiceProvider = Provider((ref) => ExportService());

class ExportNotifier extends StateNotifier<bool> {
  final ExportService _service;
  ExportNotifier(this._service) : super(false);

  Future<void> exportApplicants(List<Application> apps) async {
    state = true;
    try {
      final path = await _service.exportApplicantsToCSV(apps);
      if (path != null) {
        await Share.shareXFiles([XFile(path)], text: 'Be Practical - Applicant Export');
      }
    } finally {
      state = false;
    }
  }
}

final exportNotifierProvider = StateNotifierProvider<ExportNotifier, bool>((ref) {
  return ExportNotifier(ref.watch(exportServiceProvider));
});

