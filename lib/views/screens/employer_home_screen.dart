import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/application_model.dart';
import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';
import '../tabs/employers_listings_tab.dart';
import '../tabs/employer_post_tab.dart';
import '../tabs/employer_suggestion_tab.dart';  // ← AI tab
import '../tabs/employer_profile_tab.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _currentIndex = 0;

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return ChangeNotifierProvider(
    create: (_) => EmployerViewModel(),
    child: Builder(
      builder: (context) {
        final tabs = [
      _EmployerDashboardTab(
          onNavigate: (i) => setState(() => _currentIndex = i)),
      const EmployerListingsTab(),
      const EmployerPostTab(),
      const EmployerSuggestionsTab(),   // ← AI tab (no employerId needed)
      const EmployerProfileTab(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          selectedLabelStyle: AppTextStyles.labelSmall
              .copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
          unselectedLabelStyle: AppTextStyles.labelSmall,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Iconsax.home), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.briefcase), label: 'Listings'),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.add_circle), label: 'Post'),
            // ← Changed from Applicants to AI tab
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_rounded), label: 'AI Picks'),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.profile_circle), label: 'Profile'),
          ],
        ),
      ),
    );
      },
    ),
  );
  }
}

// ── Dashboard Tab ─────────────────────────────────────────────────────────────

class _EmployerDashboardTab extends StatelessWidget {
  final void Function(int index) onNavigate;
  const _EmployerDashboardTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final vm     = context.watch<EmployerViewModel>();
    final uid    = authVM.currentUser?.uid ?? '';
    final name   = (authVM.currentUser?.displayName ?? 'Employer').split(' ').first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<InternshipModel>>(
      stream: vm.getMyListings(uid),
      builder: (context, listingSnap) {
        final listings = listingSnap.data ?? [];

        return StreamBuilder<List<ApplicationModel>>(
          stream: vm.getAllMyApplicants(uid),
          builder: (context, appSnap) {
            final apps     = appSnap.data ?? [];
            final accepted = vm.getAcceptedCount(apps);
            final active   = vm.getActiveListingCount(listings);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                SliverToBoxAdapter(child: _TopBar(name: name, isDark: isDark)),

                // ── OVERVIEW ──
                _SectionLabel(label: 'OVERVIEW'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _OverviewCard(
                      listings: listings,
                      apps: apps,
                      active: active,
                      accepted: accepted,
                      onNavigate: onNavigate,
                      isDark: isDark,
                    ),
                  ),
                ),

                // ── HIRING FUNNEL ──
                _SectionLabel(label: 'HIRING FUNNEL'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _HiringFunnelCard(
                      total: apps.length,
                      reviewed: apps.where((a) => a.status == 'reviewed').length,
                      shortlisted: apps.where((a) => a.status == 'shortlisted').length,
                      accepted: accepted,
                      listings: listings,
                      isDark: isDark,
                      onViewAll: () => onNavigate(3),
                    ),
                  ),
                ),

                // ── ACTIVE LISTINGS ──
                _SectionLabel(label: 'ACTIVE LISTINGS'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _ActiveListingsCard(
                      listings: listings.take(3).toList(),
                      apps: apps,
                      vm: vm,
                      isDark: isDark,
                      onManageAll: () => onNavigate(1),
                    ),
                  ),
                ),

                // ── RECENT APPLICANTS ──
                _SectionLabel(label: 'RECENT APPLICANTS'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _RecentApplicantsCard(
                      apps: vm.getRecentApplications(apps, limit: 5),
                      vm: vm,
                      isDark: isDark,
                      // CHANGED: pushes full applicants screen instead of
                      // navigating to AI Picks tab (tab 3)
                      onViewAll: () => onNavigate(3),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String name;
  final bool isDark;
  const _TopBar({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            // Greeting + title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_greeting()}, $name 👋',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Employer Dashboard',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell with indigo accent
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.20),
                ),
              ),
              child: const Icon(
                Iconsax.notification,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overview Card ─────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final List<InternshipModel> listings;
  final List<ApplicationModel> apps;
  final int active;
  final int accepted;
  final void Function(int) onNavigate;
  final bool isDark;

  const _OverviewCard({
    required this.listings,
    required this.apps,
    required this.active,
    required this.accepted,
    required this.onNavigate,
    required this.isDark,
  });

  double get _rate => apps.isEmpty ? 0 : (accepted / apps.length * 100);

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        children: [
          // ── 4 colourful stat tiles ──
          Row(
            children: [
              _StatTile(
                value: '$active',
                label: 'Active',
                sub: '${listings.where((l) => !l.isActive).length} paused',
                tileColor: AppColors.primary.withOpacity(0.10),
                valueColor: AppColors.primary,
                subColor: AppColors.warning,
                icon: Iconsax.briefcase,
                isDark: isDark,
              ),
              _StatTile(
                value: '${apps.length}',
                label: 'Applicants',
                sub: 'total',
                tileColor: AppColors.secondary.withOpacity(0.10),
                valueColor: AppColors.secondary,
                subColor: AppColors.secondary,
                icon: Iconsax.people,
                isDark: isDark,
              ),
              _StatTile(
                value: '${_rate.toStringAsFixed(0)}%',
                label: 'Accept rate',
                sub: 'all time',
                tileColor: AppColors.success.withOpacity(0.10),
                valueColor: AppColors.success,
                subColor: AppColors.success,
                icon: Iconsax.tick_circle,
                isDark: isDark,
              ),
              _StatTile(
                value: '$accepted',
                label: 'Accepted',
                sub: 'interns',
                tileColor: AppColors.warning.withOpacity(0.10),
                valueColor: AppColors.warning,
                subColor: AppColors.warning,
                icon: Iconsax.user_tick,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
            color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
            height: 1,
          ),
          const SizedBox(height: 14),

          // ── Quick action chips ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionChip(
                  icon: Iconsax.add_circle,
                  label: 'Post internship',
                  color: AppColors.primary,
                  onTap: () => onNavigate(2),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Picks',
                  color: AppColors.secondary,
                  onTap: () => onNavigate(3),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Iconsax.briefcase,
                  label: 'My listings',
                  color: AppColors.success,
                  onTap: () => onNavigate(1),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String sub;
  final Color tileColor;
  final Color valueColor;
  final Color subColor;
  final IconData icon;
  final bool isDark;

  const _StatTile({
    required this.value,
    required this.label,
    required this.sub,
    required this.tileColor,
    required this.valueColor,
    required this.subColor,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: valueColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              style: AppTextStyles.bodySmall.copyWith(
                color: subColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hiring Funnel Card ────────────────────────────────────────────────────────

class _HiringFunnelCard extends StatelessWidget {
  final int total;
  final int reviewed;
  final int shortlisted;
  final int accepted;
  final List<InternshipModel> listings;
  final bool isDark;
  final VoidCallback onViewAll;

  const _HiringFunnelCard({
    required this.total,
    required this.reviewed,
    required this.shortlisted,
    required this.accepted,
    required this.listings,
    required this.isDark,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Iconsax.chart, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Applicant pipeline',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'AI Picks →',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _FunnelRow(label: 'Applied',     count: total,       total: total, barColor: AppColors.primary,   isDark: isDark),
          const SizedBox(height: 8),
          _FunnelRow(label: 'Reviewed',    count: reviewed,    total: total, barColor: AppColors.secondary, isDark: isDark),
          const SizedBox(height: 8),
          _FunnelRow(label: 'Shortlisted', count: shortlisted, total: total, barColor: AppColors.warning,   isDark: isDark),
          const SizedBox(height: 8),
          _FunnelRow(label: 'Accepted',    count: accepted,    total: total, barColor: AppColors.success,   isDark: isDark),
        ],
      ),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color barColor;
  final bool isDark;

  const _FunnelRow({
    required this.label,
    required this.count,
    required this.total,
    required this.barColor,
    required this.isDark,
  });

  double get _fraction => total == 0 ? 0 : (count / total).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                // Track
                Container(
                  height: 26,
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: 26,
                  width: c.maxWidth * _fraction,
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 10),
                  child: count > 0
                      ? Text(
                    '$count',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 30,
          child: Text(
            total == 0 ? '0%' : '${(_fraction * 100).round()}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: barColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Active Listings Card ──────────────────────────────────────────────────────

class _ActiveListingsCard extends StatelessWidget {
  final List<InternshipModel> listings;
  final List<ApplicationModel> apps;
  final EmployerViewModel vm;
  final bool isDark;
  final VoidCallback onManageAll;

  const _ActiveListingsCard({
    required this.listings,
    required this.apps,
    required this.vm,
    required this.isDark,
    required this.onManageAll,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Iconsax.briefcase, size: 16, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 10),
                  Text('My internships',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              GestureDetector(
                onTap: onManageAll,
                child: Text(
                  'Manage all →',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (listings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Iconsax.briefcase, size: 40,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  const SizedBox(height: 10),
                  Text(
                    'No active listings yet.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...listings.map((l) {
              final listingApps = apps.where((a) => a.internshipId == l.id).toList();
              final pending     = listingApps.where((a) => a.status == 'pending').length;
              final shortlisted = listingApps.where((a) => a.status == 'shortlisted').length;
              return _ListingRow(
                internship: l,
                totalApplicants: listingApps.length,
                pending: pending,
                shortlisted: shortlisted,
                isDark: isDark,
              );
            }),
        ],
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  final InternshipModel internship;
  final int totalApplicants;
  final int pending;
  final int shortlisted;
  final bool isDark;

  const _ListingRow({
    required this.internship,
    required this.totalApplicants,
    required this.pending,
    required this.shortlisted,
    required this.isDark,
  });

  // Consistent colour per company initial
  Color get _avatarColor {
    const cols = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.accent,
    ];
    return cols[internship.company.codeUnitAt(0) % cols.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;
    // CHANGED: use 3-state status instead of just isActive bool
    final statusLabel = internship.isEnded ? 'Ended'
        : internship.isActive ? 'Active' : 'Paused';
    final statusColor = internship.isEnded ? AppColors.lightTextSecondary
        : internship.isActive ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      // CHANGED: summary-only row, no toggle button
      // Employer taps "Manage all →" to go to Listings tab for actions
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Center(
              child: Text(
                internship.company.isNotEmpty
                    ? internship.company[0].toUpperCase()
                    : '?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(internship.title,
                    style: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${internship.type} · ${internship.duration} · ${internship.stipend}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (totalApplicants > 0)
                      _MiniChip(label: '$totalApplicants applicants', color: AppColors.primary),
                    if (pending > 0)
                      _MiniChip(label: '$pending pending', color: AppColors.warning),
                    if (shortlisted > 0)
                      _MiniChip(label: '$shortlisted shortlisted', color: AppColors.secondary),
                    // CHANGED: 3-state status badge, read-only
                    _MiniChip(
                      label: statusLabel,
                      color: statusColor,
                      outlined: !internship.isActive,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _MiniChip({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: outlined ? color.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Recent Applicants Card ────────────────────────────────────────────────────

class _RecentApplicantsCard extends StatelessWidget {
  final List<ApplicationModel> apps;
  final EmployerViewModel vm;
  final bool isDark;
  final VoidCallback onViewAll;

  const _RecentApplicantsCard({
    required this.apps,
    required this.vm,
    required this.isDark,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Iconsax.people, size: 16, color: AppColors.success),
                  ),
                  const SizedBox(width: 10),
                  Text('Latest activity',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all →',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (apps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Iconsax.people, size: 40,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  const SizedBox(height: 10),
                  Text(
                    'No applicants yet.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...apps.asMap().entries.map((e) {
              final i   = e.key;
              final app = e.value;
              return Column(
                children: [
                  _ApplicantRow(app: app, vm: vm, isDark: isDark),
                  if (i < apps.length - 1)
                    Divider(
                      color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                      height: 1,
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _ApplicantRow extends StatelessWidget {
  final ApplicationModel app;
  final EmployerViewModel vm;
  final bool isDark;

  const _ApplicantRow({required this.app, required this.vm, required this.isDark});

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted':    return AppColors.success;
      case 'rejected':    return AppColors.error;
      case 'shortlisted': return AppColors.warning;
      case 'reviewed':    return AppColors.info;
      default:            return AppColors.warning;
    }
  }

  // Pick avatar colour from app palette using applicant name
  Color _avatarColor() {
    const cols = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.accent,
      AppColors.warning,
    ];
    if (app.applicantName.isEmpty) return cols[0];
    return cols[app.applicantName.codeUnitAt(0) % cols.length];
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color       = _avatarColor();
    final statusColor = _statusColor(app.status);
    final initials    = app.applicantName.trim().split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Coloured avatar circle
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              initials.isNotEmpty ? initials : '?',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.applicantName,
                    style: AppTextStyles.labelMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${app.internshipTitle} · ${_timeAgo(app.appliedAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Coloured status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.25)),
            ),
            child: Text(
              vm.getStatusLabel(app.status),
              style: AppTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Card Wrapper ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── All Applicants Screen (pushed from Recent Applicants "View all") ──────────
// Shows every applicant across all the employer's listings, grouped by listing.
// Employer can Accept, Shortlist, or Reject from here.

class AllApplicantsScreen extends StatelessWidget {
  final String employerId;
  const AllApplicantsScreen({super.key, required this.employerId});

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted':    return AppColors.success;
      case 'rejected':    return AppColors.error;
      case 'shortlisted': return AppColors.warning;
      case 'reviewed':    return AppColors.info;
      case 'closed':      return const Color(0xFF94A3B8);
      default:            return AppColors.warning;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepted':    return 'Accepted';
      case 'rejected':    return 'Not Selected';
      case 'shortlisted': return 'Shortlisted';
      case 'reviewed':    return 'Under Review';
      case 'closed':      return 'Position Closed';
      default:            return 'Pending';
    }
  }

  Color _avatarColor(String name) {
    const cols = [
      AppColors.primary, AppColors.secondary, AppColors.success,
      AppColors.accent, AppColors.warning,
    ];
    if (name.isEmpty) return cols[0];
    return cols[name.codeUnitAt(0) % cols.length];
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployerViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: Text('All Applicants',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: vm.getAllMyApplicants(employerId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final apps = snap.data ?? [];
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.people, size: 56,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  const SizedBox(height: 16),
                  Text('No applicants yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      )),
                ],
              ),
            );
          }

          // Group by internship title for clarity
          final grouped = <String, List<ApplicationModel>>{};
          for (final app in apps) {
            grouped.putIfAbsent(app.internshipTitle, () => []).add(app);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing group header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 3, height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value.length} applicant${entry.value.length != 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Applicant cards
                  ...entry.value.map((app) {
                    final color = _avatarColor(app.applicantName);
                    final statusColor = _statusColor(app.status);
                    final initials = app.applicantName.trim().split(' ')
                        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
                    final isClosed = app.status == 'closed';
                    final isDecided = ['accepted', 'rejected'].contains(app.status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03),
                              blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: color.withOpacity(0.15),
                                child: Text(initials.isNotEmpty ? initials : '?',
                                    style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 12),
                              // Name + email + time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(app.applicantName,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(fontWeight: FontWeight.w700)),
                                    Text(app.applicantEmail,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Applied ${_timeAgo(app.appliedAt)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor.withOpacity(0.3)),
                                ),
                                child: Text(_statusLabel(app.status),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: statusColor, fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ],
                          ),
                          // Action buttons — only for undecided, non-closed applicants
                          if (!isClosed && !isDecided) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Accept',
                                    color: AppColors.success,
                                    onTap: () => vm.acceptApplicant(app.id),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Shortlist',
                                    color: AppColors.warning,
                                    onTap: () => vm.shortlistApplicant(app.id),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Reject',
                                    color: AppColors.error,
                                    onTap: () => vm.rejectApplicant(app.id),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                    height: 24,
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color, fontWeight: FontWeight.w700,
          )),
    );
  }
}