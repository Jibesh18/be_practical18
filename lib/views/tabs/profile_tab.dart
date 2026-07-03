import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user_model.dart';


class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return SafeArea(
      child: StreamBuilder<UserModel?>(
        stream: authVM.watchUserProfile(user.uid),
        builder: (context, snap) {
          final userModel = snap.data;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Avatar + name ──
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        user.displayName?.isNotEmpty == true
                            ? user.displayName![0].toUpperCase()
                            : '?',
                        style: AppTextStyles.headlineLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName ?? 'User',
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Intern Seeker',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Bio ──
              if (userModel?.bio.isNotEmpty == true) ...[
                _SectionLabel(label: 'About Me', isDark: isDark),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    userModel!.bio,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Skills ──
              if (userModel?.skills.isNotEmpty == true) ...[
                _SectionLabel(label: 'My Skills', isDark: isDark),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: userModel!.skills
                      .map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ── Settings ──
              _ProfileTile(
                icon: Iconsax.edit,
                label: 'Edit Profile',
                isDark: isDark,
                onTap: () => _showEditProfileSheet(
                    context, userModel, isDark),
              ),

              _ProfileTile(
                icon: Iconsax.info_circle,
                label: 'Help & Support',
                isDark: isDark,
                onTap: () {},
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),

              _ProfileTile(
                icon: Iconsax.logout,
                label: 'Logout',
                isDark: isDark,
                color: AppColors.error,
                onTap: () async {
                  await authVM.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileSheet(
      BuildContext context, UserModel? userModel, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(userModel: userModel),
    );
  }
}

// ── Edit Profile Sheet ────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserModel? userModel;
  const _EditProfileSheet({this.userModel});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameC = TextEditingController();
  final _bioC = TextEditingController();
  final _skillC = TextEditingController();
  final List<String> _skills = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.userModel;
    _nameC.text = u?.name ?? '';
    _bioC.text = u?.bio ?? '';
    _skills.addAll(u?.skills ?? []);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _bioC.dispose();
    _skillC.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillC.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() {
      _skills.add(s);
      _skillC.clear();
    });
  }

  Future<void> _save() async {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await authVM.updateProfile(
        uid: user.uid,
        name: _nameC.text.trim(),
        bio: _bioC.text.trim(),
        skills: List.from(_skills),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.6,
      builder: (_, scrollC) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Edit Profile',
                      style: AppTextStyles.headlineMedium
                          .copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollC,
                padding: const EdgeInsets.all(20),
                children: [
                  // Name
                  Text('Full Name', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameC,
                    decoration: InputDecoration(
                      hintText: 'Your full name',
                      prefixIcon:
                      const Icon(Iconsax.user, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bio
                  Text('About Me', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioC,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                      'Tell employers about yourself, your goals, and experience...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Skills
                  Text('My Skills', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Add skills that match what employers look for',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skillC,
                          decoration: InputDecoration(
                            hintText: 'e.g. Flutter, Python, Figma',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onFieldSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  if (_skills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map((s) => Chip(
                        label: Text(s,
                            style: AppTextStyles.labelSmall
                                .copyWith(
                                color: AppColors.primary)),
                        backgroundColor:
                        AppColors.primary.withOpacity(0.08),
                        deleteIcon: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.primary),
                        onDeleted: () =>
                            setState(() => _skills.remove(s)),
                      ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white),
                      )
                          : Text('Save Profile',
                          style: AppTextStyles.button
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style:
            AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c =
        color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: c, size: 20),
        title: Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: c, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: c.withOpacity(0.4), size: 20),
        onTap: onTap,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}