import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/auth_provider.dart';

class CompanyDrawer extends ConsumerWidget {
  const CompanyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryBlue = const Color(0xFF1565C0);
    final user = ref.watch(authProvider).user;
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          _buildHeader(user, primaryBlue),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _tile(context, Icons.dashboard_rounded, 'Dashboard', '/company-dashboard', location),
                _tile(context, Icons.add_circle_outline_rounded, 'Post Internship', '/post-internship', location),
                _tile(context, Icons.work_outline_rounded, 'Manage Internships', '/manage-internships', location),
                _tile(context, Icons.people_outline_rounded, 'Applications', '/applicants', location),
                _tile(context, Icons.video_camera_front_outlined, 'Interviews', '/interviews', location),
                _tile(context, Icons.chat_bubble_outline_rounded, 'Messages', '/messages', location),
                _tile(context, Icons.bar_chart_rounded, 'Analytics', '/analytics', location),
                _tile(context, Icons.card_membership_rounded, 'Membership', '/membership', location),
                _tile(context, Icons.business_rounded, 'Company Profile', '/company-profile', location),
                _tile(context, Icons.notifications_none_rounded, 'Notifications', '/notifications', location),
                _tile(context, Icons.settings_outlined, 'Settings', '/company-settings', location),
                const Divider(indent: 20, endIndent: 20, height: 40),
                _tile(context, Icons.help_outline_rounded, 'Help Center', '/support', location),
                _tile(context, Icons.description_outlined, 'Terms of Service', '/privacy', location),
                _tile(context, Icons.logout_rounded, 'Logout', '/login', location, isDestructive: true, onTap: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user, Color primary) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      color: primary,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.business_rounded, color: Color(0xFF1565C0), size: 30)),
          const SizedBox(height: 16),
          Text(user?.name ?? 'Be Practical Academy', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(user?.email ?? 'recruiter@bepractical.tech', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String path, String currentPath, {bool isDestructive = false, VoidCallback? onTap}) {
    final bool isSelected = currentPath == path;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF1565C0) : (isDestructive ? Colors.red : Colors.black54)),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isDestructive ? Colors.red : Colors.black87)),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1565C0).withValues(alpha: 0.05),
      onTap: onTap ?? () => context.push(path),
    );
  }
}

