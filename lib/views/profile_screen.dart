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
            const SnackBar(content: Text('Profile identity updated! 📸'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const Scaffold(body: LoadingWidget());
    _bioController.text = user.bio;

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
            flexibleSpace: FlexibleSpaceBar(
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
                  _HeaderGlow(color: AppColors.accent.withValues(alpha: 0.15), size: 250),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _showAvatarPicker(context),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2))),
                              Hero(
                                tag: 'avatar',
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: user.avatar.contains('/') ? FileImage(File(user.avatar)) : null,
                                  child: user.avatar.contains('/') ? null : Text(user.avatar, style: const TextStyle(fontSize: 48)),
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 18),
                        Text(user.name, style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        Text(user.role.toUpperCase(), style: AppTextStyles.caption.copyWith(color: AppColors.accent, letterSpacing: 2)),
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
                tabs: const [Tab(text: 'OVERVIEW'), Tab(text: 'SETTINGS')],
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
                  PrimaryCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditingBio)
                          TextField(controller: _bioController, maxLines: 4, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Tell your story...'))
                        else
                          Text(user.bio.isEmpty ? "Start your career story..." : user.bio, style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: Colors.black87)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _isEditingBio = !_isEditingBio),
                            icon: Icon(_isEditingBio ? Icons.check_circle : Icons.edit_note),
                            label: Text(_isEditingBio ? 'Save Aura' : 'Edit Story'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SecondaryButton(label: 'Sign Out', icon: Icons.power_settings_new_rounded, onPressed: () => ref.read(authProvider.notifier).logout()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Identity Style', style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickerOption(icon: Icons.camera_alt_rounded, label: 'Camera', onTap: () => _pickImage(ImageSource.camera)),
                _PickerOption(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: () => _pickImage(ImageSource.gallery)),
              ],
            ),
          ],
        ),
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
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HeaderStat(label: 'LEVEL', value: '${user.level}'),
                _StatDivider(),
                _HeaderStat(label: 'RANK', value: '#42'),
                _StatDivider(),
                _HeaderStat(label: 'MATCH', value: '98%'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: _tabBar);
  }
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override Widget build(BuildContext context) => Text(title, style: AppTextStyles.heading.copyWith(fontSize: 17, fontWeight: FontWeight.w900));
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  const _HeaderStat({required this.label, required this.value});
  @override Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
    Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1)),
  ]);
}

class _StatDivider extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.1));
}

class _HeaderGlow extends StatelessWidget {
  final Color color;
  final double size;
  const _HeaderGlow({required this.color, required this.size});
  @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)])));
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.onTap});
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 30)),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
