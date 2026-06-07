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

/// Safe URL launcher
Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open link")),
      );
    }
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: LoadingWidget(message: "Loading dashboard..."),
      );
    }

    final internships = ref.watch(allInternshipsProvider);
    final skills = ref.watch(skillsProvider);
    final notifications = ref.watch(unreadCountProvider);

    final name = user.name.split(' ').first;
    final progress = ((user.xp ?? 0) / (user.nextLevelXp ?? 1)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ───────── HEADER ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Evening",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _NotificationIcon(count: notifications),
                  ],
                ),
              ),
            ),

            // ───────── CONTENT ─────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  const SizedBox(height: 16),

                  // ───────── PROGRESS CARD ─────────
                  _ProgressCard(
                    xp: user.xp ?? 0,
                    nextXp: user.nextLevelXp ?? 100,
                    progress: progress,
                  ),

                  const SizedBox(height: 20),

                  // ───────── ACADEMY CARD ─────────
                  _AcademyCard(
                    onTap: () =>
                        _openUrl(context, "https://bepractical.tech"),
                  ),

                  const SizedBox(height: 24),

                  // ───────── INTERNSHIPS ─────────
                  _SectionHeader(
                    title: "Recommended Internships",
                    onTap: () => context.push('/internships'),
                  ),

                  const SizedBox(height: 12),

                  internships.when(
                    data: (data) => _FeaturedInternship(data: data),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text("Failed to load internships"),
                  ),

                  const SizedBox(height: 24),

                  // ───────── SKILLS ─────────
                  const _SectionHeader(title: "Skill Paths"),

                  const SizedBox(height: 12),

                  skills.when(
                    data: (data) => Column(
                      children: data.take(3).map((s) {
                        final completed =
                            ((s.lessons.length * 0.7) * 10).clamp(0, 100);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PrimaryCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: completed / 100,
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$completed% completed",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ───────────────────────── COMPONENTS ─────────────────────────
//

class _ProgressCard extends StatelessWidget {
  final int xp;
  final int nextXp;
  final double progress;

  const _ProgressCard({
    required this.xp,
    required this.nextXp,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Learning Progress",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$xp XP",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Next level: $nextXp XP",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademyCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AcademyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF111827), Color(0xFF1F2937)],
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Build Real Projects",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "100+ Projects • Internship Support",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FeaturedInternship extends StatelessWidget {
  final List<Internship> data;

  const _FeaturedInternship({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text("No internships available");
    }

    final i = data.first;

    return PrimaryCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(child: Text(i.logo)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i.position,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  i.company,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: i.matchPercentage / 100,
                ),
                const SizedBox(height: 4),
                Text("${i.matchPercentage}% match"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const Spacer(),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text("See all"),
          ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final int count;

  const _NotificationIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(Icons.notifications_none_rounded,
            size: 28, color: Color(0xFF111827)),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          )
      ],
    );
  }
}
