import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import '../tabs/intern_search_tab.dart';
import '../tabs/applications_tab.dart';
import '../tabs/community_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/resources_tab.dart';
import 'intern_detail_screen.dart';

// Single accent used only for the certification/resources bar — everything
// else on this screen stays black/white as before.
const Color _kAccent = Color(0xFF3B82F6); // blue-500

// Prepends "Rs " to a stipend value for display, without double-prefixing
// values that are already "Unpaid" or already contain a currency mark.
// The raw value stored in Firestore/InternshipModel stays untouched —
// this only affects what's shown on screen.
String _formatStipend(String stipend) {
  final trimmed = stipend.trim();
  if (trimmed.isEmpty) return trimmed;
  final lower = trimmed.toLowerCase();
  if (lower == 'unpaid' || lower.startsWith('rs') || trimmed.startsWith('₹')) {
    return trimmed;
  }
  return 'Rs $trimmed';
}

// ── Main Screen with Bottom Nav ───────────────────────────────────────────────
// Bottom nav: Home · Applied · Resources · Community · Profile.
// The dedicated "Search" tab slot was removed — search is now reached from
// the header search field on Home, which pushes InternSearchTab as a normal
// route instead of occupying a nav slot.

class InternHomeTab extends StatelessWidget {
  const InternHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final pages = [
          const _InternHomeContent(),
          const ApplicationsScreen(),
          const ResourcesTab(),
          const CommunityTab(),
          const ProfileTab(),
        ];

        // Guard against an out-of-range index left over from before the
        // Search tab was removed (e.g. a saved index of 4 pointing at what
        // used to be Profile at position 5).
        final safeIndex = viewModel.currentIndex.clamp(0, pages.length - 1);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor:
            isDark ? AppColors.darkBg : AppColors.lightBg,
            body: IndexedStack(
              index: safeIndex,
              children: pages,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                unselectedItemColor: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                selectedLabelStyle: AppTextStyles.labelSmall
                    .copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: AppTextStyles.labelSmall,
                currentIndex: safeIndex,
                onTap: viewModel.setIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.document),
                    label: 'Applied',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.book_1),
                    label: 'Resources',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.people),
                    label: 'Community',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.profile_circle),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Home Tab Content ──────────────────────────────────────────────────────────

class _InternHomeContent extends StatelessWidget {
  const _InternHomeContent();

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final internVM = context.watch<InternshipViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, user?.displayName ?? 'Intern'),

            // ── Resources teaser ──
            const SizedBox(height: 20),
            _ResourcesTeaserCard(isDark: isDark),

            // ── AI Recommended Jobs (Job-Creative style) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AI Recommended Jobs',
                      style: AppTextStyles.headlineMedium
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 19)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InternSearchTab()),
                    ),
                    child: Text('Show all',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: StreamBuilder(
                stream: internVM.allInternships,
                builder: (context, snapshot) {
                  final all = snapshot.data ?? [];
                  if (all.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'No internships posted yet — check back soon!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }
                  final recommended = all.take(6).toList();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: recommended.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => _RecommendedJobCard(
                      internship: recommended[i],
                      featured: i == 0, // first card gets the black "featured" treatment
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // ── Recent applications ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Text('Recent Applications',
                  style: AppTextStyles.titleLarge
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            if (user != null)
              StreamBuilder<List<ApplicationModel>>(
                stream: internVM.getMyApplications(user.uid),
                builder: (context, snapshot) {
                  final apps = snapshot.data ?? [];
                  if (apps.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      child: _EmptyApplicationsHint(isDark: isDark),
                    );
                  }
                  final recent = apps.take(4).toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _ApplicationCard(app: recent[i]),
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // "Job Creative" style header: plain background, bold black headline,
  // search pill + separate square filter button (no gradient banner).
  Widget _buildHeader(BuildContext context, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logobp.png',
                height: 52,
                errorBuilder: (_, __, ___) => Icon(Icons.school, color: textColor, size: 52),
              ),
              const SizedBox(width: 10),
              Text('Be Practical',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: textColor,
                  )),
              const Spacer(),
              _ProfileAvatarButton(name: name, isDark: isDark),
            ],
          ),
          const SizedBox(height: 22),
          Text('Good morning, $name',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          Text(
            'Find Your\nNext Internship',
            style: AppTextStyles.displayLarge.copyWith(
              color: textColor, height: 1.08, fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InternSearchTab()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightDivider,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.search_normal,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Search for internships',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InternSearchTab()),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Iconsax.setting_4,
                      color: isDark ? AppColors.darkBg : Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Resources teaser card ─────────────────────────────────────────────────────

// ── Profile avatar (header, right side) ───────────────────────────────────────
// Tapping jumps straight to the Profile tab instead of pushing a new route,
// since Profile already lives in the bottom nav — no need for a second path
// to the same screen.
class _ProfileAvatarButton extends StatelessWidget {
  final String name;
  final bool isDark;
  const _ProfileAvatarButton({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => context.read<DashboardViewModel>().setIndex(4), // Profile tab
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightDivider,
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Center(
          child: Text(
            initial,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Resources teaser card ─────────────────────────────────────────────────────
class _ResourcesTeaserCard extends StatelessWidget {
  final bool isDark;
  const _ResourcesTeaserCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: GestureDetector(
        onTap: () => context.read<DashboardViewModel>().setIndex(2), // Resources tab
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Free skill courses',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 2),
                    Text('Certifications from Google, IBM & more',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state hint ──────────────────────────────────────────────────────────

class _EmptyApplicationsHint extends StatelessWidget {
  final bool isDark;
  const _EmptyApplicationsHint({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(Iconsax.document, size: 36,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          const SizedBox(height: 10),
          Text('No applications yet',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Browse recommended internships above and apply to get started.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}

// ── Reusable Cards ────────────────────────────────────────────────────────────

// "Job Creative" style card: the first (featured) card in the row is solid
// black with white text; the rest are white/surface cards with a black
// border-less look and a company-initial logo tile.
//
// Option A layout (approved): compact single-row card — logo, title, and
// company/location all on one row, stipend + urgency tag below. No
// bookmark icon (removed per feedback — it wasn't wired to anything).
class _RecommendedJobCard extends StatelessWidget {
  final InternshipModel internship;
  final bool featured;
  final bool isDark;
  const _RecommendedJobCard({
    required this.internship,
    required this.featured,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = featured
        ? (isDark ? Colors.white : AppColors.lightTextPrimary)
        : (isDark ? AppColors.darkSurface : Colors.white);
    final fg = featured
        ? (isDark ? AppColors.darkBg : Colors.white)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final fgMuted = featured
        ? fg.withOpacity(0.65)
        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary);
    final logoBg = featured ? fg.withOpacity(0.15) : AppColors.lightDivider;

    // Rough "days left" indicator derived from postedAt, purely cosmetic —
    // mirrors the reference design's urgency tag.
    final daysLeft = 30 - (DateTime.now().difference(internship.postedAt).inDays % 30);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => InternshipDetailScreen(internship: internship)),
      ),
      child: Container(
        width: 270,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: featured
              ? null
              : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: featured
              ? [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 6))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: logoBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      internship.company.isNotEmpty ? internship.company[0].toUpperCase() : '?',
                      style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(internship.title,
                          style: AppTextStyles.labelMedium.copyWith(color: fg, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${internship.company} · ${internship.location}',
                          style: AppTextStyles.labelSmall.copyWith(color: fgMuted),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: logoBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(internship.type,
                      style: AppTextStyles.labelSmall.copyWith(color: fg, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatStipend(internship.stipend),
                    style: AppTextStyles.bodySmall.copyWith(color: fgMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  daysLeft <= 0 ? 'Closing soon' : '$daysLeft days left',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: daysLeft <= 5 ? AppColors.error : fgMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;
  const _ApplicationCard({required this.app});

  Color get _statusColor {
    switch (app.status) {
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'shortlisted': return AppColors.warning;
      case 'reviewed': return AppColors.secondary;
      default: return AppColors.lightTextTertiary;
    }
  }

  String get _statusLabel {
    switch (app.status) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      case 'shortlisted': return 'Shortlisted';
      case 'reviewed': return 'Reviewed';
      default: return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                app.company.isNotEmpty ? app.company[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.internshipTitle,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(app.company,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    )),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border:
              Border.all(color: _statusColor.withOpacity(0.4)),
            ),
            child: Text(
              _statusLabel,
              style: AppTextStyles.labelSmall
                  .copyWith(color: _statusColor),
            ),
          ),
        ],
      ),
    );
  }
}