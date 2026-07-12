// lib/views/screens/internship_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/incomplete_profile_dialog.dart';
import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';

class InternshipDetailScreen extends StatefulWidget {
  final InternshipModel internship;

  const InternshipDetailScreen({super.key, required this.internship});

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  bool _applying = false;
  bool? _hasApplied; // null = checking, true/false = known

  @override
  void initState() {
    super.initState();
    _checkApplied();
  }

  Future<void> _checkApplied() async {
    final authVM = context.read<AuthViewModel>();
    final uid = authVM.currentUser?.uid;
    if (uid == null) {
      setState(() => _hasApplied = false);
      return;
    }
    final vm = context.read<InternshipViewModel>();
    final result = await vm.hasApplied(widget.internship.id, uid);
    if (mounted) setState(() => _hasApplied = result);
  }

  Future<void> _apply() async {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    if (user == null || _applying) return;

    final profile = await authVM.getUserProfile(user.uid);
    if (!(profile?.isProfileComplete ?? false)) {
      if (!mounted) return;
      showIncompleteProfileDialog(context);
      return;
    }

    setState(() => _applying = true);

    final vm = context.read<InternshipViewModel>();
    final success = await vm.apply(
      internship: widget.internship,
      applicantId: user.uid,
      applicantName: user.displayName ?? 'Anonymous',
      applicantEmail: user.email ?? '',
    );

    if (!mounted) return;
    setState(() {
      _applying = false;
      if (success) _hasApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Applied to ${widget.internship.company}! 🎉'
              : vm.applyError ?? 'Something went wrong.',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Color _avatarColor(String name) {
    const colours = [
      Color(0xFF4F46E5),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ];
    if (name.isEmpty) return colours[0];
    return colours[name.codeUnitAt(0) % colours.length];
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'remote':
        return const Color(0xFF10B981);
      case 'on-site':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.internship;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarColor = _avatarColor(i.company);
    final typeColor = _typeColor(i.type);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar with company avatar ──
          SliverAppBar(
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            pinned: true,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: avatarColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: avatarColor.withOpacity(0.25), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              i.company.isNotEmpty ? i.company[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: avatarColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          i.company,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title + type badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        i.title,
                        style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        i.type,
                        style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Meta info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetaItem(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: i.location,
                          isDark: isDark,
                        ),
                      ),
                      _vDivider(isDark),
                      Expanded(
                        child: _MetaItem(
                          icon: Icons.schedule_rounded,
                          label: 'Duration',
                          value: i.duration,
                          isDark: isDark,
                        ),
                      ),
                      _vDivider(isDark),
                      Expanded(
                        child: _MetaItem(
                          icon: Icons.payments_outlined,
                          label: 'Stipend',
                          value: i.stipend,
                          isDark: isDark,
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Skills
                if (i.skills.isNotEmpty) ...[
                  _SectionHeader(title: 'Skills required', isDark: isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: i.skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Description
                _SectionHeader(title: 'About this internship', isDark: isDark),
                const SizedBox(height: 10),
                Text(
                  i.description.isNotEmpty ? i.description : 'No description provided.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Requirements
                _SectionHeader(title: 'Requirements', isDark: isDark),
                const SizedBox(height: 10),
                Text(
                  i.requirements.isNotEmpty ? i.requirements : 'No specific requirements listed.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Posted by
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business_rounded, size: 18,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Posted by ${i.employerName.isNotEmpty ? i.employerName : i.company}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),

      // ── Sticky apply button at bottom ──
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: _hasApplied == null
                ? const Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : (_hasApplied!)
                ? Container(
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text('Already Applied',
                      style: AppTextStyles.button.copyWith(color: AppColors.success)),
                ],
              ),
            )
                : ElevatedButton(
              onPressed: _applying ? null : _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _applying
                  ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text('Apply Now',
                  style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _vDivider(bool isDark) => Container(
    width: 1,
    height: 40,
    color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
  );
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18,
            color: highlight ? AppColors.success : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        const SizedBox(height: 6),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 11,
            )),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.success : null,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}