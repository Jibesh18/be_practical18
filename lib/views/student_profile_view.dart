import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../model/user.dart';
import '../viewmodel/chat_provider.dart';

class StudentProfileView extends ConsumerWidget {
  final User student;
  const StudentProfileView({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(student.name.isNotEmpty ? student.name : 'Student Profile',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(student, primaryBlue),
            const SizedBox(height: 32),
            if (student.bio.isNotEmpty) _buildSection('About', student.bio),
            const Divider(height: 48),
            if (student.skills.isNotEmpty) _buildSection('Skills', student.skills.join(', ')),
            const Divider(height: 48),
            _buildExperience(student),
            const Divider(height: 48),
            _buildEducation(student),
            const SizedBox(height: 32),
            _buildSocialLinks(student, primaryBlue),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionFAB(context, ref, primaryBlue),
    );
  }

  Widget _buildHeader(User s, Color primary) {
    return Row(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: primary.withValues(alpha: 0.1),
          child: Text(s.name.isNotEmpty ? s.name[0] : '?',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              Text(s.headline.isNotEmpty ? s.headline : 'Student',
                  style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text(s.location.isNotEmpty ? s.location : 'Remote',
                      style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1565C0))),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
      ],
    );
  }

  Widget _buildExperience(User s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1565C0))),
        const SizedBox(height: 16),
        if (s.experience.isEmpty)
          const Text('No experience listed', style: TextStyle(color: Colors.black38)),
        ...s.experience.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.work_history_outlined, color: Colors.black26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(e.company, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    Text(e.duration, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildEducation(User s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1565C0))),
        const SizedBox(height: 16),
        if (s.education.isEmpty)
          const Text('No education listed', style: TextStyle(color: Colors.black38)),
        ...s.education.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school_outlined, color: Colors.black26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.institute, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${e.degree} • ${e.batch}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    Text('Grade: ${e.grade}', style: const TextStyle(color: Colors.black38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSocialLinks(User s, Color primary) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (s.linkedinUrl.isNotEmpty) _socialChip('LinkedIn', Icons.link, primary),
        if (s.githubUrl.isNotEmpty) _socialChip('GitHub', Icons.code, primary),
        if (s.portfolioUrl.isNotEmpty) _socialChip('Portfolio', Icons.language, primary),
      ],
    );
  }

  Widget _socialChip(String label, IconData icon, Color primary) {
    return Chip(
      avatar: Icon(icon, size: 16, color: primary),
      label: Text(label, style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
      backgroundColor: primary.withValues(alpha: 0.05),
      side: BorderSide.none,
    );
  }

  Widget _buildActionFAB(BuildContext context, WidgetRef ref, Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final roomId = await ref.read(chatNotifierProvider.notifier).getOrCreateRoom(
                    student.id,
                    {'name': student.name, 'avatar': student.avatar}
                );
                if (context.mounted) context.push('/chat/$roomId');
              },
              icon: const Icon(Icons.message_rounded, color: Colors.white),
              label: const Text('MESSAGE STUDENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 54, width: 54,
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.star_rounded, color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}
