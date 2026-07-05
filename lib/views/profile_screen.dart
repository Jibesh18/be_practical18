import 'dart:io';
import 'dart:ui'; // CRITICAL: Fixes ImageFilter Error
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/auth_provider.dart';
import '../components/buttons/secondary_button.dart';
import '../components/common/skill_badge.dart';
import '../components/common/loading_widget.dart';
import '../components/cards/primary_card.dart';
import '../components/buttons/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _bioController;
  late TabController _tabController;
  bool _isEditingBio = false;
  bool _isSavingBio = false;
  String? _lastInitializedBio;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        await ref.read(authProvider.notifier).updateAvatar(pickedFile.path);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Identity Updated ✨'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Identity Style', style: AppTextStyles.heading.copyWith(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _PickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text('Update Name', style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Full Name",
              filled: true,
              fillColor: AppColors.primary.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            PrimaryButton(
              isFullWidth: false,
              label: 'Update',
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(authProvider.notifier).updateName(controller.text.trim());
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBioSave() async {
    setState(() => _isSavingBio = true);
    ref.read(authProvider.notifier).updateBio(_bioController.text.trim());
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isEditingBio = false;
        _isSavingBio = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Career Aura Updated ✨'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const Scaffold(body: LoadingWidget());

    if (_lastInitializedBio != user.bio) {
      _lastInitializedBio = user.bio;
      _bioController.text = user.bio;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  _HeaderGlow(color: AppColors.accent.withValues(alpha: 0.2), size: 300),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showAvatarPicker(context),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                                ),
                              ).animate(onPlay: (c) => c.repeat()).scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)).fadeOut(),
                              Hero(
                                tag: 'avatar',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 2.5),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 54,
                                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                                    backgroundImage: user.avatar.contains('/') ? FileImage(File(user.avatar)) : null,
                                    child: user.avatar.contains('/') ? null : Text(user.avatar, style: const TextStyle(fontSize: 48)),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () => _showEditNameDialog(context, user.name),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(user.name, style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified_rounded, color: AppColors.accent, size: 20),
                            ],
                          ),
                        ),
                        Text(user.headline, style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1.1)),
                        const SizedBox(height: 28),
                        _buildMetricPanel(user),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.accent,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'OVERVIEW'),
                  Tab(text: 'SETTINGS'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Career Story'),
                  const SizedBox(height: 12),
                  _buildBioCard(user),
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Top Skills'),
                  const SizedBox(height: 16),
                  _buildSkillsList(user),
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Preferences'),
                  const SizedBox(height: 16),
                  _buildSettingsGroup(context),
                  const SizedBox(height: 48),
                  SecondaryButton(
                    label: 'Sign Out session',
                    icon: Icons.power_settings_new_rounded,
                    onPressed: () => _showLogoutConfirmation(context),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPanel(dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HeaderStat(label: 'LEVEL', value: '${user.level}'),
                _StatDivider(),
                _HeaderStat(label: 'STREAK', value: '${user.stats.learningStreak}d'),
                _StatDivider(),
                _HeaderStat(label: 'MATCH', value: '98%'),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildBioCard(dynamic user) {
    return PrimaryCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditingBio)
            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 200,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
              decoration: const InputDecoration(
                hintText: 'Tell your career story...',
                border: InputBorder.none,
              ),
            )
          else
            Text(user.bio.isEmpty ? "No bio set yet. Start your story..." : user.bio,
                style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.6,
                  color: Colors.black87,
                  fontStyle: user.bio.isEmpty ? FontStyle.italic : FontStyle.normal,
                )
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _isSavingBio
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton.icon(
              onPressed: () => _isEditingBio ? _handleBioSave() : setState(() => _isEditingBio = true),
              icon: Icon(_isEditingBio ? Icons.check_circle_rounded : Icons.edit_note_rounded, size: 20),
              label: Text(_isEditingBio ? 'Save Aura' : 'Edit Story'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSkillsList(dynamic user) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: user.skills.asMap().entries.map<Widget>((entry) {
        return SkillBadge(skill: entry.value.name, level: 'Pro')
            .animate()
            .scale(delay: (500 + (entry.key * 50)).ms, curve: Curves.easeOutBack);
      }).toList(),
    );
  }

  Widget _buildSettingsGroup(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _SettingTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            color: Colors.blue,
            onTap: () => context.push('/notifications'),
          ),
          _SettingTile(
            icon: Icons.shield_moon_outlined,
            title: 'Privacy & Security',
            color: Colors.deepPurple,
            onTap: () => context.push('/privacy'),
          ),
          _SettingTile(
            icon: Icons.help_center_outlined,
            title: 'Support Center',
            color: Colors.orange,
            onTap: () {},
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to end your premium session?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/splash');
              },
              child: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.background.withValues(alpha: 0.8),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: AppTextStyles.heading.copyWith(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5));
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  const _HeaderStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
    ],
  );
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.1));
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.title, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color, size: 22)
    ),
    title: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
  );
}

class _HeaderGlow extends StatelessWidget {
  final Color color;
  final double size;
  const _HeaderGlow({this.color = AppColors.accent, this.size = 200});
  @override
  Widget build(BuildContext context) => Positioned(
    top: -50, right: -50,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0)])
      ),
    ),
  );
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}
