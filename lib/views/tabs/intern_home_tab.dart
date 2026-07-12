import 'package:be_practical18/views/tabs/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/community_post.dart';
import '../../models/internship_model.dart';
import '../../models/application_model.dart';
import '../../models/user_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/community_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import '../screens/community_post_detail_screen.dart';
import '../screens/intern_detail_screen.dart';
import 'intern_search_tab.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final internVM = context.watch<InternshipViewModel>();
    final communityVM = context.watch<CommunityViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = (user?.displayName ?? 'there').split(' ').first;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [

        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting + avatar
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()}, $firstName',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find your next\ninternship',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Avatar circle
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileTab()),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Text(
                            firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search bar
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InternSearchTab())),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search_rounded,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search internships, resources...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightTextPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats row — Applied / Pending / Accepted / Profile %
                  StreamBuilder<List<ApplicationModel>>(
                    stream: user != null
                        ? context.read<InternshipViewModel>().getMyApplications(user.uid)
                        : const Stream.empty(),
                    builder: (context, appSnap) {
                      final apps = appSnap.data ?? [];
                      final applied = apps.length;
                      final pending = apps.where((a) => a.status == 'pending').length;
                      final accepted = apps.where((a) => a.status == 'accepted').length;

                      return StreamBuilder<UserModel?>(
                        stream: user != null ? authVM.watchUserProfile(user.uid) : const Stream.empty(),
                        builder: (context, userSnap) {
                          final profile = userSnap.data;
                          final profilePct = _profilePercent(profile);

                          return Row(
                            children: [
                              _StatBox(value: '$applied', label: 'Applied', isDark: isDark),
                              _StatDivider(isDark: isDark),
                              _StatBox(value: '$pending', label: 'Pending', isDark: isDark),
                              _StatDivider(isDark: isDark),
                              _StatBox(
                                value: '$accepted',
                                label: 'Accepted',
                                valueColor: accepted > 0 ? AppColors.success : null,
                                isDark: isDark,
                              ),
                              _StatDivider(isDark: isDark),
                              _StatBox(
                                value: '$profilePct%',
                                label: 'Profile',
                                valueColor: profilePct < 100 ? AppColors.warning : AppColors.success,
                                isDark: isDark,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // AI banner
                  StreamBuilder<UserModel?>(
                    stream: user != null ? authVM.watchUserProfile(user.uid) : const Stream.empty(),
                    builder: (context, userSnap) {
                      final profile = userSnap.data;
                      final hasProfile = profile != null &&
                          (profile.bio.isNotEmpty || profile.skills.isNotEmpty || profile.education.isNotEmpty);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileTab()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Iconsax.magic_star, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasProfile ? 'Your AI picks are ready' : 'Get AI-matched internships',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hasProfile
                                          ? 'Matched to your CV and skills'
                                          : 'Complete your profile to get personalised matches',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.primary.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Closing soon ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: StreamBuilder<List<InternshipModel>>(
            stream: internVM.allInternships,
            builder: (context, snap) {
              final all = snap.data ?? [];
              if (all.isEmpty) return const SizedBox.shrink();
              // Take first 4 as "closing soon" (in real world you'd sort by deadline)
              final closing = all.take(4).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Closing soon',
                    isDark: isDark,
                    onSeeAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InternSearchTab()),
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: closing.length,
                      itemBuilder: (context, i) {
                        final item = closing[i];
                        // fake days left based on index for demo
                        final days = (i + 2) * 1;
                        return _ClosingSoonCard(
                          internship: item,
                          daysLeft: days,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ── Latest openings ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: StreamBuilder<List<InternshipModel>>(
            stream: internVM.allInternships,
            builder: (context, snap) {
              final all = snap.data ?? [];
              final filtered = internVM.applyFilters(all);
              if (filtered.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Latest openings',
                    isDark: isDark,
                    onSeeAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InternSearchTab()),
                    ),
                  ),
                  ...filtered.take(5).map((internship) => _ListCard(
                    internship: internship,
                    userId: user?.uid,
                    isDark: isDark,
                  )),
                ],
              );
            },
          ),
        ),

        // ── Community highlights ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: StreamBuilder<List<CommunityPost>>(
            stream: communityVM.posts,
            builder: (context, snap) {
              final posts = snap.data ?? [];
              if (posts.isEmpty) return const SizedBox.shrink();
              final highlights = posts.take(3).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Community highlights',
                    isDark: isDark,
                    onSeeAll: () => context.read<DashboardViewModel>().setIndex(3),
                  ),
                  ...highlights.map((post) => _CommunityHighlightTile(
                    post: post,
                    isDark: isDark,
                  )),
                ],
              );
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  int _profilePercent(UserModel? p) {
    if (p == null) return 0;
    int score = 0;
    if (p.name.isNotEmpty) score += 20;
    if (p.bio.isNotEmpty) score += 20;
    if (p.skills.isNotEmpty) score += 20;
    if (p.education.isNotEmpty) score += 20;
    if (p.experience.isNotEmpty) score += 20;
    return score;
  }
}

// ── Shared widgets used by HomeTab below ──────────────────────────────────
// (Not a "Community Tab" — just the small building-block widgets this file
// uses: stat boxes, section headers, cards, etc.)

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final bool isDark;

  const _StatBox({required this.value, required this.label, this.valueColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;
  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, required this.isDark, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Show all',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClosingSoonCard extends StatelessWidget {
  final InternshipModel internship;
  final int daysLeft;
  final bool isDark;

  const _ClosingSoonCard({required this.internship, required this.daysLeft, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => InternshipDetailScreen(internship: internship))),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(internship.title,
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(internship.company,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text(
              '$daysLeft days left',
              style: AppTextStyles.bodySmall.copyWith(
                color: daysLeft <= 3 ? AppColors.error : AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatefulWidget {
  final InternshipModel internship;
  final String? userId;
  final bool isDark;

  const _ListCard({required this.internship, required this.userId, required this.isDark});

  @override
  State<_ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<_ListCard> {
  bool _applying = false;
  bool? _hasApplied;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      context.read<InternshipViewModel>()
          .hasApplied(widget.internship.id, widget.userId!)
          .then((v) { if (mounted) setState(() => _hasApplied = v); });
    }
  }

  Future<void> _apply() async {
    if (widget.userId == null || _applying || (_hasApplied ?? false)) return;
    final authVM = context.read<AuthViewModel>();
    final profile = await authVM.getUserProfile(widget.userId!);
    if (!(profile?.isProfileComplete ?? false)) {
      if (!mounted) return;
      showIncompleteProfileDialog(context);
      return;
    }
    setState(() => _applying = true);
    final user = authVM.currentUser;
    final vm = context.read<InternshipViewModel>();
    final success = await vm.apply(
      internship: widget.internship,
      applicantId: widget.userId!,
      applicantName: user?.displayName ?? 'Anonymous',
      applicantEmail: user?.email ?? '',
    );
    if (!mounted) return;
    setState(() { _applying = false; if (success) _hasApplied = true; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Applied! 🎉' : vm.applyError ?? 'Error'),
      backgroundColor: success ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => InternshipDetailScreen(internship: widget.internship))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Company avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.internship.company.isNotEmpty ? widget.internship.company[0].toUpperCase() : '?',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.internship.title,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${widget.internship.company} · ${widget.internship.location}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(widget.internship.type,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.internship.stipend,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Apply button
            GestureDetector(
              onTap: (_hasApplied ?? false) ? null : _apply,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (_hasApplied ?? false)
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.lightTextPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _applying
                    ? const Padding(padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(
                  (_hasApplied ?? false) ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  color: (_hasApplied ?? false) ? AppColors.success : Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityHighlightTile extends StatelessWidget {
  final CommunityPost post;
  final bool isDark;

  const _CommunityHighlightTile({required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.question,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(
              '${post.answerCount} answer${post.answerCount != 1 ? 's' : ''} · ${post.authorName}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Import for incomplete profile dialog
void showIncompleteProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Complete your profile', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
      content: const Text('Please add your bio, education, and at least one skill before applying.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileTab()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Go to Profile', style: AppTextStyles.button.copyWith(color: Colors.white)),
        ),
      ],
    ),
  );
}