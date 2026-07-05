import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/company_provider.dart';
import '../model/interview.dart';
import '../theme/app_text_styles.dart';

class InterviewsScreen extends ConsumerWidget {
  const InterviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviewsAsync = ref.watch(interviewsProvider);
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Interview Schedule', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month_rounded), onPressed: () {}),
        ],
      ),
      body: interviewsAsync.when(
        data: (list) => list.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                itemBuilder: (ctx, i) => _InterviewCard(interview: list[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading schedule: $e')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_camera_front_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No interviews scheduled', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text('Shortlist candidates from the Applicants tab to start scheduling.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black38)),
          ),
        ],
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final Interview interview;
  const _InterviewCard({required this.interview});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(interview.dateTime);
    final timeStr = DateFormat('hh:mm a').format(interview.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.video_call_rounded, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(interview.studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text(interview.internshipTitle, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                    Text(timeStr, style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (interview.meetingLink.isNotEmpty)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.link),
                      label: const Text('Join Meeting'),
                    ),
                  ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_calendar_rounded),
                    label: const Text('Reschedule'),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: Colors.black38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

