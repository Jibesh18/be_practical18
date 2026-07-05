import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_provider.dart';
import '../theme/app_text_styles.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> {
  final Color primaryBlue = const Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Security'),
            _settingsTile(Icons.lock_outline_rounded, 'Change Password', 'Update your login credentials', () {}),
            _settingsTile(Icons.verified_user_outlined, 'Two-Factor Authentication', 'Add an extra layer of security', () {}, trailing: _statusBadge('Disabled', Colors.orange)),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Preferences'),
            _switchTile('Email Notifications', 'Receive updates about new applicants', user?.settings.notificationsEnabled ?? true, (val) {
              ref.read(authProvider.notifier).toggleSetting('notifications', val);
            }),
            _switchTile('Push Notifications', 'Real-time alerts for messages and interviews', true, (val) {}),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Legal & About'),
            _settingsTile(Icons.description_outlined, 'Terms of Service', 'Read our platform rules', () => context.push('/terms')),
            _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data', () => context.push('/privacy')),
            _settingsTile(Icons.help_outline_rounded, 'Help Center', 'Documentation and support', () => context.push('/help')),
            
            const SizedBox(height: 48),
            _buildDangerZone(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title.toUpperCase(), style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
    );
  }

  Widget _settingsTile(IconData icon, String title, String sub, VoidCallback onTap, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black38)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.black12),
      ),
    );
  }

  Widget _switchTile(String title, String sub, bool val, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        value: val,
        onChanged: onChanged,
        activeColor: primaryBlue,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black38)),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('DANGER ZONE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withValues(alpha: 0.1))),
          child: ListTile(
            onTap: () {},
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text('Delete Company Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text('Permanently remove all jobs and data', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

