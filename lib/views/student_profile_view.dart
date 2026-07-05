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
      appBar: AppBar(title: Text(student.name), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(student, primaryBlue),
            const SizedBox(height: 32),
            _buildSection('About', student.bio),
            const Divider(height: 48),
            _buildSection('Skills', student.skills.join(', ')),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionFAB(context, ref, primaryBlue),
    );
  }

  Widget _buildProfileHeader(User s, Color primary) {
    return Row(children: [
      CircleAvatar(radius: 45, backgroundColor: primary.withOpacity(0.1), child: Text(s.name.isNotEmpty ? s.name[0] : '?', style: TextStyle(fontSize: 32, color: primary, fontWeight: FontWeight.bold))),
      const SizedBox(width: 20),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(s.headline, style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ])),
    ]);
  }

  Widget _buildSection(String title, String content) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1565C0))),
      const SizedBox(height: 12),
      Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
    ]);
  }

  Widget _buildActionFAB(BuildContext context, WidgetRef ref, Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          minimumSize: const Size.fromHeight(54), // Fixed: Corrected 'height' error
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          final roomId = await ref.read(chatNotifierProvider.notifier).getOrCreateRoom(student.id, {'name': student.name, 'avatar': student.avatar});
          if (context.mounted) context.push('/chat/$roomId');
        },
        icon: const Icon(Icons.message_rounded, color: Colors.white),
        label: const Text('MESSAGE STUDENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
