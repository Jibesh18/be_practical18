import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_provider.dart';
import '../viewmodel/company_provider.dart';
import '../viewmodel/chat_provider.dart';
import '../viewmodel/export_provider.dart';
import '../repo/auth_service.dart';
import '../model/application.dart';
import '../model/user.dart';

class ApplicantsScreen extends ConsumerWidget {
  final String? internshipId;
  const ApplicantsScreen({super.key, this.internshipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(companyApplicationsProvider);
    final isExporting = ref.watch(exportNotifierProvider);
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Talent Pipeline', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isExporting)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            IconButton(
              icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF1565C0)),
              onPressed: () => _showExportDialog(context, ref, appsAsync.value ?? []),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: appsAsync.when(
        data: (list) {
          final filteredList = internshipId != null 
              ? list.where((a) => a.internshipId == internshipId).toList() 
              : list;

          return filteredList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredList.length,
                  itemBuilder: (ctx, i) => _ApplicantCard(application: filteredList[i]),
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Sync Error: $e')),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref, List<Application> apps) {
    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to export")));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Export Pipeline Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _exportOption(Icons.table_view_rounded, 'Export Applicants (CSV)', Colors.green, () {
              Navigator.pop(ctx);
              ref.read(exportNotifierProvider.notifier).exportApplicants(apps);
            }),
            _exportOption(Icons.picture_as_pdf_rounded, 'Export Summary (PDF)', Colors.red, () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF Exporting coming soon...")));
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No candidates in pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  final Application application;
  const _ApplicantCard({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryBlue = const Color(0xFF1565C0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primaryBlue.withValues(alpha: 0.1),
          child: Text(application.studentName.isNotEmpty ? application.studentName[0] : '?', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        ),
        title: Text(application.studentName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        subtitle: Text("${application.studentCollege} • ${application.internshipTitle}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: _statusBadge(application.status),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusTimeline(application.status, primaryBlue),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionIcon(context, Icons.person_search_rounded, 'Profile', Colors.blue, () async {
                      final fullUser = await ref.read(authServiceProvider).getUserById(application.studentId);
                      if (fullUser != null && context.mounted) {
                        context.push('/view-student', extra: fullUser);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not load student profile")));
                      }
                    }),
                    _actionIcon(context, Icons.message_rounded, 'Chat', Colors.teal, () async {
                       final roomId = await ref.read(chatNotifierProvider.notifier).getOrCreateRoom(
                         application.studentId, 
                         {'name': application.studentName, 'avatar': application.studentAvatar}
                       );
                       if (context.mounted) context.push('/chat/$roomId');
                    }),
                    _actionIcon(context, Icons.star_rounded, 'Shortlist', Colors.orange, () {
                      ref.read(companyNotifierProvider.notifier).updateApplicationStatus(application.id, ApplicationStatus.shortlisted);
                    }),
                    _actionIcon(context, Icons.video_call_rounded, 'Interview', Colors.purple, () {
                       context.push('/schedule-interview', extra: application);
                    }),
                    _actionIcon(context, Icons.check_circle_rounded, 'Hire', Colors.green, () {
                       ref.read(companyNotifierProvider.notifier).updateApplicationStatus(application.id, ApplicationStatus.hired);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(ApplicationStatus current, Color primary) {
    return Row(
      children: [
        _timelineDot(true, 'Applied', primary),
        _timelineLine(current.index >= 2, primary),
        _timelineDot(current.index >= 2, 'Shortlisted', primary),
        _timelineLine(current.index >= 3, primary),
        _timelineDot(current.index >= 3, 'Interview', primary),
        _timelineLine(current.index >= 6, primary),
        _timelineDot(current.index >= 6, 'Hired', primary),
      ],
    );
  }

  Widget _timelineDot(bool active, String label, Color primary) => Column(
    children: [
      Container(
        height: 12, width: 12,
        decoration: BoxDecoration(color: active ? primary : Colors.grey[300], shape: BoxShape.circle),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: active ? primary : Colors.black26)),
    ],
  );

  Widget _timelineLine(bool active, Color primary) => Expanded(
    child: Container(height: 2, color: active ? primary : Colors.grey[200], margin: const EdgeInsets.only(bottom: 12)),
  );

  Widget _actionIcon(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _statusBadge(ApplicationStatus s) {
    Color c;
    switch(s) {
      case ApplicationStatus.shortlisted: c = Colors.orange; break;
      case ApplicationStatus.rejected: c = Colors.red; break;
      case ApplicationStatus.interviewScheduled: c = Colors.purple; break;
      case ApplicationStatus.hired: c = Colors.green; break;
      default: c = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(s.name.toUpperCase(), style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

