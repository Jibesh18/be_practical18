import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_text_styles.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Support & Help', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportHeader(primaryBlue),
            const SizedBox(height: 32),
            _sectionTitle('Direct Contact'),
            _supportCard(Icons.chat_bubble_outline_rounded, 'Live Chat', 'Average response time: 5 mins', primaryBlue, () {}),
            _supportCard(Icons.email_outlined, 'Email Support', 'support@bepractical.tech', Colors.orange, () async {
               final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'support@bepractical.tech');
               launchUrl(emailLaunchUri);
            }),
            _supportCard(Icons.phone_in_talk_outlined, 'Priority Call', 'Available for Enterprise only', Colors.green, () {}),
            
            const SizedBox(height: 32),
            _sectionTitle('Quick Help'),
            _helpTile('How to post a featured internship?'),
            _helpTile('Managing applicant assessments'),
            _helpTile('Upgrading your company membership'),
            _helpTile('Refund and billing policy'),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How can we help?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('Our recruiter success team is here to help you find the best talent.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
  );

  Widget _supportCard(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black12),
      ),
    );
  }

  Widget _helpTile(String question) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.arrow_outward_rounded, size: 18, color: Colors.black26),
      onTap: () {},
    );
  }
}

