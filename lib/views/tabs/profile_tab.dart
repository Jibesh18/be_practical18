import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
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

    // FIXED: ProfileTab used to return a bare StreamBuilder/ListView with
    // no Scaffold. That worked fine while Profile lived inside the bottom
    // nav's IndexedStack (borrowing that screen's Scaffold), but now that
    // it's reached via Navigator.push (from the home avatar, the AI banner,
    // and the incomplete-profile dialog), there's no Material ancestor —
    // so TextFormField/buttons inside (edit sheet, CV upload, logout, etc.)
    // would crash, and there was no back button either. Wrapping in a
    // Scaffold with a minimal transparent AppBar fixes both.
    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<UserModel?>(
        stream: authVM.watchUserProfile(user.uid),
        builder: (context, snap) {
          final u = snap.data;
          final name = user.displayName ?? 'User';
          final email = user.email ?? '';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
          final profilePct = _profilePercent(u);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Hero header ──────────────────────────────────────────
              Container(
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: AppColors.primary.withOpacity(0.12),
                              child: Text(initial,
                                  style: AppTextStyles.displayLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  )),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showEditProfileSheet(context, u, isDark),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(name, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(email, style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        )),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text('Intern Seeker', style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700,
                          )),
                        ),
                        const SizedBox(height: 20),

                        // Profile completion bar
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Profile completion',
                                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                                  ),
                                  Text('$profilePct%',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: profilePct == 100 ? AppColors.success : AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: profilePct / 100,
                                  minHeight: 6,
                                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    profilePct == 100 ? AppColors.success : AppColors.primary,
                                  ),
                                ),
                              ),
                              if (profilePct < 100) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Add ${_missingFields(u)} to improve your match score',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Profile sections ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About Me
                    _ProfileCard(
                      title: 'About Me',
                      icon: Iconsax.user,
                      isDark: isDark,
                      isEmpty: u?.bio.isEmpty ?? true,
                      emptyLabel: 'Add a bio to tell employers about yourself',
                      onEdit: () => _showEditProfileSheet(context, u, isDark),
                      child: u?.bio.isNotEmpty == true
                          ? Text(u!.bio, style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.6,
                      ))
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Education
                    _ProfileCard(
                      title: 'Education',
                      icon: Iconsax.book,
                      isDark: isDark,
                      isEmpty: u?.education.isEmpty ?? true,
                      emptyLabel: 'Add your education details',
                      onEdit: () => _showEditProfileSheet(context, u, isDark),
                      child: u?.education.isNotEmpty == true
                          ? Row(
                        children: [
                          const Icon(Iconsax.book, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text(u!.education, style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ))),
                        ],
                      )
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Experience
                    _ProfileCard(
                      title: 'Experience',
                      icon: Iconsax.briefcase,
                      isDark: isDark,
                      isEmpty: u?.experience.isEmpty ?? true,
                      emptyLabel: 'Add your experience',
                      onEdit: () => _showEditProfileSheet(context, u, isDark),
                      child: u?.experience.isNotEmpty == true
                          ? Row(
                        children: [
                          const Icon(Iconsax.briefcase, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text(u!.experience, style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ))),
                        ],
                      )
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Skills
                    _ProfileCard(
                      title: 'Skills',
                      icon: Iconsax.code,
                      isDark: isDark,
                      isEmpty: u?.skills.isEmpty ?? true,
                      emptyLabel: 'Add your skills to get better AI matches',
                      onEdit: () => _showEditProfileSheet(context, u, isDark),
                      child: u?.skills.isNotEmpty == true
                          ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: u!.skills.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Text(s, style: const TextStyle(
                            color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600,
                          )),
                        )).toList(),
                      )
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Links & CV
                    if ((u?.linkedinUrl.isNotEmpty == true) ||
                        (u?.githubUrl.isNotEmpty == true) ||
                        (u?.cvUploaded == true))
                      _ProfileCard(
                        title: 'Links & CV',
                        icon: Iconsax.link,
                        isDark: isDark,
                        isEmpty: false,
                        emptyLabel: '',
                        onEdit: () => _showEditProfileSheet(context, u, isDark),
                        child: Column(
                          children: [
                            if (u!.linkedinUrl.isNotEmpty)
                              _LinkTile(icon: Iconsax.link, label: 'LinkedIn', url: u.linkedinUrl, isDark: isDark),
                            if (u.githubUrl.isNotEmpty) ...[
                              if (u.linkedinUrl.isNotEmpty) const SizedBox(height: 8),
                              _LinkTile(icon: Iconsax.code, label: 'GitHub', url: u.githubUrl, isDark: isDark),
                            ],
                            if (u.cvUploaded) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _viewCv(context, u.uid),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.document_text, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          u.cvFileName.isNotEmpty ? u.cvFileName : 'View CV / Resume',
                                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Settings tiles
                    _SettingsTile(
                      icon: Iconsax.edit,
                      label: 'Edit Profile',
                      isDark: isDark,
                      onTap: () => _showEditProfileSheet(context, u, isDark),
                    ),
                    _SettingsTile(
                      icon: Iconsax.info_circle,
                      label: 'Help & Support',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
                    const SizedBox(height: 4),
                    _SettingsTile(
                      icon: Iconsax.logout,
                      label: 'Logout',
                      isDark: isDark,
                      color: AppColors.error,
                      onTap: () async {
                        await authVM.logout();
                        if (!context.mounted) return;
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _profilePercent(UserModel? u) {
    if (u == null) return 0;
    int score = 0;
    if (u.name.isNotEmpty) score += 20;
    if (u.bio.isNotEmpty) score += 20;
    if (u.skills.isNotEmpty) score += 20;
    if (u.education.isNotEmpty) score += 20;
    if (u.experience.isNotEmpty) score += 20;
    return score;
  }

  String _missingFields(UserModel? u) {
    if (u == null) return 'your details';
    final missing = <String>[];
    if (u.bio.isEmpty) missing.add('bio');
    if (u.skills.isEmpty) missing.add('skills');
    if (u.education.isEmpty) missing.add('education');
    if (u.experience.isEmpty) missing.add('experience');
    if (missing.isEmpty) return '';
    return missing.take(2).join(' & ');
  }

  void _showEditProfileSheet(BuildContext context, UserModel? userModel, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(userModel: userModel),
    );
  }
}

// ── View CV ───────────────────────────────────────────────────────────────────

Future<void> _viewCv(BuildContext context, String uid) async {
  final authVM = context.read<AuthViewModel>();
  final data = await authVM.fetchCvData(uid);
  if (data == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not load CV.'), backgroundColor: AppColors.error),
    );
    return;
  }
  final bytes = base64Decode(data['data'] as String);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${data['fileName']}');
  await file.writeAsBytes(bytes);
  await OpenFilex.open(file.path);
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
  final _educationC = TextEditingController();
  final _experienceC = TextEditingController();
  final _linkedinC = TextEditingController();
  final _githubC = TextEditingController();
  final List<String> _skills = [];
  bool _isLoading = false;
  bool _isUploadingCV = false;
  bool _cvUploaded = false;
  String _cvFileName = '';

  @override
  void initState() {
    super.initState();
    final u = widget.userModel;
    _nameC.text = u?.name ?? '';
    _bioC.text = u?.bio ?? '';
    _educationC.text = u?.education ?? '';
    _experienceC.text = u?.experience ?? '';
    _linkedinC.text = u?.linkedinUrl ?? '';
    _githubC.text = u?.githubUrl ?? '';
    _cvUploaded = u?.cvUploaded ?? false;
    _cvFileName = u?.cvFileName ?? '';
    _skills.addAll(u?.skills ?? []);
  }

  @override
  void dispose() {
    for (final c in [_nameC, _bioC, _skillC, _educationC, _experienceC, _linkedinC, _githubC]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSkill() {
    final s = _skillC.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() { _skills.add(s); _skillC.clear(); });
  }

  Future<void> _pickAndUploadCV() async {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    if (user == null) return;
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    setState(() => _isUploadingCV = true);
    try {
      final file = File(result.files.single.path!);
      await authVM.uploadCV(uid: user.uid, file: file);
      setState(() { _cvUploaded = true; _cvFileName = result.files.single.name; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV uploaded!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isUploadingCV = false);
    }
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
        education: _educationC.text.trim(),
        experience: _experienceC.text.trim(),
        linkedinUrl: _linkedinC.text.trim(),
        githubUrl: _githubC.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: AppColors.error),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                )),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Edit Profile', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollC,
                padding: const EdgeInsets.all(20),
                children: [
                  _Field(label: 'Full Name', controller: _nameC, hint: 'Your full name', icon: Iconsax.user),
                  _Field(label: 'Bio', controller: _bioC, hint: 'Tell employers about yourself...', maxLines: 3),
                  _Field(label: 'Education', controller: _educationC,
                      hint: 'e.g. BSc Computer Science, TU, 2022–2026', icon: Iconsax.book, maxLines: 2),
                  _Field(label: 'Experience', controller: _experienceC,
                      hint: 'Any projects, internships, or work experience', icon: Iconsax.briefcase, maxLines: 2),

                  // Skills
                  Text('Skills', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skillC,
                          decoration: const InputDecoration(hintText: 'e.g. Flutter, Python, Figma'),
                          onFieldSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addSkill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_skills.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _skills.map((s) => Chip(
                        label: Text(s),
                        onDeleted: () => setState(() => _skills.remove(s)),
                        backgroundColor: AppColors.primarySurface,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                        labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _Field(label: 'LinkedIn URL', controller: _linkedinC,
                      hint: 'https://linkedin.com/in/yourname', icon: Iconsax.link,
                      keyboardType: TextInputType.url),
                  _Field(label: 'GitHub URL', controller: _githubC,
                      hint: 'https://github.com/yourusername', icon: Iconsax.code,
                      keyboardType: TextInputType.url),

                  // CV Upload
                  Text('CV / Resume (PDF)', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _cvUploaded ? Iconsax.document_text : Iconsax.document_upload,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _cvUploaded ? _cvFileName : 'No CV uploaded yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        _isUploadingCV
                            ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                            : TextButton(
                          onPressed: _pickAndUploadCV,
                          child: Text(_cvUploaded ? 'Replace' : 'Upload',
                              style: const TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('PDF only, under 700KB',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        )),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes'),
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final bool isEmpty;
  final String emptyLabel;
  final VoidCallback onEdit;
  final Widget? child;

  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.isEmpty,
    required this.emptyLabel,
    required this.onEdit,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Text('Edit', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 12),
            child!,
          ] else if (isEmpty) ...[
            const SizedBox(height: 10),
            Text(emptyLabel, style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            )),
          ],
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final bool isDark;

  const _LinkTile({required this.icon, required this.label, required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.labelMedium),
            const Spacer(),
            const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _SettingsTile({required this.icon, required this.label, required this.onTap, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: c, size: 20),
        title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: c, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right_rounded, color: c.withOpacity(0.4), size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}