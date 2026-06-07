import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../viewmodel/auth_provider.dart';
import '../viewmodel/internship_provider.dart';
import '../viewmodel/skill_provider.dart';
import '../viewmodel/notification_provider.dart';
import '../model/internship.dart';
import '../components/cards/primary_card.dart';
import '../components/common/loading_widget.dart';

/// ───────────────────────── ACTIONS ─────────────────────────
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

    final internshipsAsync = ref.watch(allInternshipsProvider);
    final skillsAsync = ref.watch(skillsProvider);
    final notifications = ref.watch(unreadCountProvider);

    final name = user.name.split(" ").first;
    final progress =
        ((user.xp ?? 0) / (user.nextLevelXp ?? 1)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ───────── HEADER ─────────
            SliverToBoxAdapter(
              child: _Header(
                name: name,
                notifications: notifications,
              ),
            ),

            // ───────── BODY ─────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  const SizedBox(height: 14),

                  _ProgressCard(
                    xp: user.xp ?? 0,
                    next: user.nextLevelXp ?? 100,
                    progress: progress,
                  ),

                  const SizedBox(height: 14),

                  _FeatureCard(
                    onTap: () =>
                        _openUrl(context, "https://bepractical.tech"),
                  ),

                  const SizedBox(height: 20),

                  const _SectionTitle("Internships"),

                  const SizedBox(height: 10),

                  _InternshipSection(data: internshipsAsync),

                  const SizedBox(height: 20),

                  const _SectionTitle("Skill Paths"),

                  const SizedBox(height: 10),

                  _SkillSection(data: skillsAsync),

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
// ───────────────────────── HEADER ─────────────────────────
//
class _Header extends StatelessWidget {
  final String name;
  final int notifications;

  const _Header({
    required this.name,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          _Avatar(name),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good evening",
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

          _Notification(count: notifications),
        ],
      ),
    );
  }
}

//
// ───────────────────────── PROGRESS ─────────────────────────
//
class _ProgressCard extends StatelessWidget {
  final int xp;
  final int next;
  final double progress;

  const _ProgressCard({
    required this.xp,
    required this.next,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(16),
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

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
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

//
// ───────────────────────── FEATURE CARD ─────────────────────────
//
class _FeatureCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FeatureCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Projects • Internships • Career Growth",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

//
// ───────────────────────── INTERNSHIPS ─────────────────────────
//
class _InternshipSection extends StatelessWidget {
  final AsyncValue<List<Internship>> data;

  const _InternshipSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return data.when(
      loading: () => const _Skeleton(),
      error: (_, __) => const Text("Failed to load internships"),
      data: (list) {
        if (list.isEmpty) return const Text("No internships");

        return Column(
          children: list.take(1).map((i) {
            return PrimaryCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(child: Text(i.logo)),

                  const SizedBox(width: 10),

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
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
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
          }).toList(),
        );
      },
    );
  }
}

//
// ───────────────────────── SKILLS ─────────────────────────
//
class _SkillSection extends StatelessWidget {
  final AsyncValue data;

  const _SkillSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return data.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (list) {
        final skills = (list as List).take(3);

        return Column(
          children: skills.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PrimaryCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: 0.65,
                      minHeight: 6,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "65% completed",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

//
// ───────────────────────── SMALL UI ─────────────────────────
//
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
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
        const Icon(Icons.notifications_none,
            color: Color(0xFF111827)),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
