import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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

class _InternshipDetailScreenState extends State<InternshipDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _applying = false;
  bool? _hasApplied;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkApplied();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkApplied() async {
    final uid = context.read<AuthViewModel>().currentUser?.uid;
    if (uid == null) { setState(() => _hasApplied = false); return; }
    final result = await context.read<InternshipViewModel>().hasApplied(widget.internship.id, uid);
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
    setState(() { _applying = false; if (success) _hasApplied = true; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Applied to ${widget.internship.company}! 🎉' : vm.applyError ?? 'Something went wrong.'),
      backgroundColor: success ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Color get _typeColor {
    switch (widget.internship.type.toLowerCase()) {
      case 'remote': return const Color(0xFF10B981);
      case 'on-site': return AppColors.primary;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.internship;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Column(
        children: [
          // ── Hero header ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back button row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        // Share button placeholder
                        IconButton(
                          icon: const Icon(Icons.ios_share_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Company + title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company logo
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Text(
                              i.company.isNotEmpty ? i.company[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i.title,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                i.company,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Stipend
                                  Text(
                                    i.stipend,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('·', style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                                  const SizedBox(width: 8),
                                  // Type badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _typeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      i.type,
                                      style: TextStyle(
                                        color: _typeColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Meta row
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                      ),
                    ),
                    child: Row(
                      children: [
                        _MetaChip(icon: Icons.location_on_outlined, label: i.location, isDark: isDark),
                        _VertDivider(isDark: isDark),
                        _MetaChip(icon: Icons.access_time_rounded, label: i.duration, isDark: isDark),
                        _VertDivider(isDark: isDark),
                        _MetaChip(icon: Icons.calendar_today_outlined,
                            label: '${i.postedAt.day}/${i.postedAt.month}/${i.postedAt.year}',
                            isDark: isDark),
                      ],
                    ),
                  ),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Description'),
                      Tab(text: 'Company'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab content ──────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Description tab
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  children: [
                    // Skills
                    if (i.skills.isNotEmpty) ...[
                      _SectionTitle(title: 'Required Skills', isDark: isDark),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: i.skills.map((s) => Container(
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
                      ),
                      const SizedBox(height: 24),
                    ],

                    // About
                    _SectionTitle(title: 'About this Internship', isDark: isDark),
                    const SizedBox(height: 10),
                    Text(
                      i.description.isNotEmpty ? i.description : 'No description provided.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Qualifications
                    _SectionTitle(title: 'Requirements', isDark: isDark),
                    const SizedBox(height: 10),
                    ...i.requirements.split('\n').where((l) => l.trim().isNotEmpty).map((line) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 7, right: 10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  line.trim(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ).toList(),
                    if (i.requirements.isEmpty)
                      Text(
                        'No specific requirements listed.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),

                // Company tab
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    i.company.isNotEmpty ? i.company[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(i.company, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                                    if (i.location.isNotEmpty)
                                      Text(i.location, style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
                          const SizedBox(height: 12),
                          _InfoRow(icon: Icons.person_outline_rounded,
                              label: 'Posted by', value: i.employerName.isNotEmpty ? i.employerName : i.company, isDark: isDark),
                          const SizedBox(height: 10),
                          _InfoRow(icon: Icons.work_outline_rounded,
                              label: 'Type', value: i.type, isDark: isDark),
                          const SizedBox(height: 10),
                          _InfoRow(icon: Icons.timer_outlined,
                              label: 'Duration', value: i.duration, isDark: isDark),
                          const SizedBox(height: 10),
                          _InfoRow(icon: Icons.payments_outlined,
                              label: 'Stipend', value: i.stipend, isDark: isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Sticky Apply button ──────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: _hasApplied == null
                ? const Center(child: SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2)))
                : _hasApplied!
                ? Container(
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
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
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _applying
                  ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Apply Now',
                  style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _MetaChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          const SizedBox(height: 4),
          Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  final bool isDark;
  const _VertDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 32,
    color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        )),
        Expanded(child: Text(value, style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ))),
      ],
    );
  }
}