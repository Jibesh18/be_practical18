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

/// ───────────────────────── URL HANDLER ─────────────────────────
Future<void> _openLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open link")),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }
}

/// ───────────────────────── HOME SCREEN ─────────────────────────
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
    final unread = ref.watch(unreadCountProvider);

    final name = user.name.split(" ").first;
    final progress =
        ((user.xp ?? 0) / (user.nextLevelXp ?? 1)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ───────── HEADER ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _Avatar(name: name),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _Notification(count: unread),
                  ],
                ),
              ),
            ),

            // ───────── BODY ─────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  const SizedBox(height: 16),

                  // ───── PROGRESS ─────
                  _Progress(
                    xp: user.xp ?? 0,
                    next: user.nextLevelXp ?? 100,
                    value: progress,
                  ),

                  const SizedBox(height: 20),

                  // ───── ACADEMY ─────
                  _HeroCard(
                    onTap: () => _openLink(
                      context,
                      "https://bepractical.tech",
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ───── INTERNSHIPS ─────
                  const _Section(title: "Recommended Internships"),

                  const SizedBox(height: 12),

                  internships.when(
                    data: (data) => _InternshipCard(data: data),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text("Failed to load data"),
                  ),

                  const SizedBox(height: 24),

                  // ───── SKILLS ─────
                  const _Section(title: "Skill Paths"),

                  const SizedBox(height: 12),

                  skills.when(
                    data: (data) => Column(
                      children: data.take(3).map((s) {
                        final percent = 70.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PrimaryCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                LinearProgressIndicator(
                                  value: percent / 100,
                                  minHeight: 6,
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "$percent% completed",
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

                  const SizedBox(height: 90),
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

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Notification extends StatelessWidget {
  final int count;
  const _Notification({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(
          Icons.notifications_none_rounded,
          size: 26,
          color: Color(0xFF111827),
        ),
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
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  final int xp;
  final int next;
  final double value;

  const _Progress({
    required this.xp,
    required this.next,
    required this.value,
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
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "$xp XP",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Next milestone: $next XP",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF111827),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Build Real Experience",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Projects • Internships • Mentorship",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final List<Internship> data;

  const _InternshipCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text("No internships found");
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

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}
