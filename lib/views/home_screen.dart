import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodel/auth_provider.dart';
import '../viewmodel/internship_provider.dart';
import '../viewmodel/skill_provider.dart';
import '../viewmodel/notification_provider.dart';
import '../model/internship.dart';
import '../components/cards/primary_card.dart';
import '../components/common/loading_widget.dart';

/// Launch a URL safely, surfacing an error snackbar on failure.
Future<void> _launchURL(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link. Try again later.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong opening the link.')),
      );
    }
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Show a loading screen while auth initialises; never crash on null user.
    if (user == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading…'),
      );
    }

    final internshipsAsync = ref.watch(allInternshipsProvider);
    final skillsAsync = ref.watch(skillsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    // Derive a safe first name — fall back to full name if no space is found.
    final firstName = user.name.contains(' ')
        ? user.name.split(' ').first
        : user.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    _AppLogo(),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Be Practical',
                          style: AppTextStyles.heading.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Hi, $firstName 👋',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _NotificationBadge(
                      count: unreadCount,
                      onTap: () => context.push('/notifications'),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  // ── XP Progress ─────────────────────────────────────────
                  _XPProgressCard(
                    xp: user.xp ?? 0,
                    nextLevelXp: (user.nextLevelXp ?? 1).clamp(1, double.infinity).toInt(),
                  ),

                  const SizedBox(height: 28),

                  // ── Academy Promo ────────────────────────────────────────
                  _AcademyPromoCard(
                    onVisit: () => _launchURL(context, 'https://bepractical.tech'),
                  ),

                  const SizedBox(height: 28),

                  // ── Internships ──────────────────────────────────────────
                  _SectionHeader(
                    title: 'Recommended For You',
                    action: 'Explore all',
                    onAction: () => context.push('/internships'),
                  ),
                  const SizedBox(height: 14),
                  _InternshipCarousel(
                    asyncData: internshipsAsync,
                    onTap: (id) => context.push('/internship/$id'),
                  ),

                  const SizedBox(height: 28),

                  // ── Skills ───────────────────────────────────────────────
                  const _SectionHeader(title: 'Active Skill Paths'),
                  const SizedBox(height: 14),
                  _SkillsList(
                    asyncData: skillsAsync,
                    onTap: () => context.push('/skills'),
                  ),

                  // Bottom safe-area padding for nav bar.
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

/// App logo tile. Falls back to initials on asset error.
class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Image.asset(
          'assets/images/applogo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Text(
              'BP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// XP progress card with clamped, safe progress value.
class _XPProgressCard extends StatelessWidget {
  final int xp;
  final int nextLevelXp;

  const _XPProgressCard({required this.xp, required this.nextLevelXp});

  @override
  Widget build(BuildContext context) {
    // Clamp to [0, 1] so the bar never overflows or goes negative.
    final progress = (xp / nextLevelXp).clamp(0.0, 1.0);

    return PrimaryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP PROGRESS',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.muted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$xp / $nextLevelXp XP',
                style: AppTextStyles.label.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Academy promo banner — pure stateless, no side effects.
class _AcademyPromoCard extends StatelessWidget {
  final VoidCallback onVisit;

  const _AcademyPromoCard({required this.onVisit});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.auraGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PREMIUM ENROLLMENT',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Be Practical Academy',
                    style: AppTextStyles.subheading.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Unlock 100+ industrial projects\nand guaranteed internship placement.',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: onVisit,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Visit Academy',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.school_rounded, size: 64, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

/// Horizontal internship card carousel — handles all async states explicitly.
class _InternshipCarousel extends StatelessWidget {
  final AsyncValue<List<Internship>> asyncData;
  final void Function(String id) onTap;

  const _InternshipCarousel({required this.asyncData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => _ErrorTile(
        message: 'Could not load internships.',
        // Expose a retry if the provider supports it:
        // onRetry: () => ref.invalidate(allInternshipsProvider),
      ),
      data: (internships) {
        if (internships.isEmpty) {
          return const _EmptyTile(message: 'No internships available right now.');
        }
        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: internships.length,
            itemBuilder: (context, index) {
              final i = internships[index];
              final isFree = i.price == 'Free';
              return SizedBox(
                width: 240,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < internships.length - 1 ? 14 : 0,
                  ),
                  child: PrimaryCard(
                    onTap: () => onTap(i.id),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(i.logo,
                                style: const TextStyle(fontSize: 26)),
                            _PriceChip(label: i.price, isFree: isFree),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          i.position,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          i.company,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                size: 13, color: AppColors.accent),
                            const SizedBox(width: 3),
                            Text(
                              '${i.matchPercentage}% match',
                              style: AppTextStyles.label.copyWith(
                                fontSize: 11,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Vertical skills list — handles all async states explicitly.
class _SkillsList extends StatelessWidget {
  final AsyncValue asyncData;
  final VoidCallback onTap;

  const _SkillsList({required this.asyncData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const _ErrorTile(message: 'Could not load skill paths.'),
      data: (data) {
        final skills = (data as List).take(4).toList();
        if (skills.isEmpty) {
          return const _EmptyTile(message: 'No active skill paths yet.');
        }
        return Column(
          children: [
            for (int idx = 0; idx < skills.length; idx++) ...[
              PrimaryCard(
                onTap: onTap,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.code_rounded,
                          color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skills[idx].name ?? 'Unnamed skill',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${(skills[idx].lessons as List?)?.length ?? 0} lessons',
                            style:
                                AppTextStyles.caption.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.border),
                  ],
                ),
              ),
              if (idx < skills.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

// ── Shared small components ────────────────────────────────────────────────────

class _PriceChip extends StatelessWidget {
  final String label;
  final bool isFree;
  const _PriceChip({required this.label, required this.isFree});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFree
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isFree ? AppColors.success : AppColors.secondary,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.subheading.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action!,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotificationBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Clamp displayed count to 99+.
    final label = count > 99 ? '99+' : '$count';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: count > 0
            ? '$count unread notifications'
            : 'Notifications',
        button: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            if (count > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String message;
  const _ErrorTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Text(message,
              style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String message;
  const _EmptyTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(message,
          style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
    );
  }
}
