import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/company_provider.dart';
import '../model/internship.dart';
import 'package:go_router/go_router.dart';

class ManageInternshipsScreen extends ConsumerWidget {
  const ManageInternshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final internshipsAsync = ref.watch(myInternshipsProvider);
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Manage Internships', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
        ],
      ),
      body: internshipsAsync.when(
        data: (list) => list.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                itemBuilder: (ctx, i) => _InternshipCard(internship: list[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No internships posted yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/post-internship'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Post Your First Internship', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InternshipCard extends ConsumerWidget {
  final Internship internship;
  const _InternshipCard({required this.internship});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusChip(status: internship.status),
              PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == 'delete') {
                    await ref.read(companyNotifierProvider.notifier).deleteInternship(internship.id);
                  } else if (val == 'pause') {
                    ref.read(companyServiceProvider).updateInternshipStatus(internship.id, InternshipStatus.paused);
                  } else if (val == 'resume') {
                    ref.read(companyServiceProvider).updateInternshipStatus(internship.id, InternshipStatus.active);
                  } else if (val == 'close') {
                    ref.read(companyServiceProvider).updateInternshipStatus(internship.id, InternshipStatus.closed);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                  if (internship.status == InternshipStatus.active)
                    const PopupMenuItem(value: 'pause', child: Text('Pause Applications')),
                  if (internship.status == InternshipStatus.paused)
                    const PopupMenuItem(value: 'resume', child: Text('Resume Applications')),
                  const PopupMenuItem(value: 'close', child: Text('Close Program')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete Permanent', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(internship.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text('${internship.category} • ${internship.location}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          const Divider(height: 32),
          Row(
            children: [
              _stat(Icons.people_alt_outlined, '${internship.applicantCount} Applicants'),
              const SizedBox(width: 16),
              _stat(Icons.visibility_outlined, '${internship.viewCount} Views'),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push('/applicants?id=${internship.id}'),
                icon: const Icon(Icons.visibility),
                label: const Text('VIEW CANDIDATES'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String text) => Row(children: [Icon(icon, size: 16, color: Colors.black38), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))]);
}

class _StatusChip extends StatelessWidget {
  final InternshipStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch(status) {
      case InternshipStatus.active: color = Colors.green; break;
      case InternshipStatus.paused: color = Colors.orange; break;
      case InternshipStatus.closed: color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

