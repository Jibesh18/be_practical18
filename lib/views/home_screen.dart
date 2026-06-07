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

/// ───────────────────────── LINK HANDLER ─────────────────────────
Future<void> _open(BuildContext context, String url) async {
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

/// ───────────────────────── HOME ─────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: LoadingWidget(message: "Loading..."),
      );
    }

    final internships = ref.watch(allInternshipsProvider);
    final skills = ref.watch(skillsProvider);
    final notifications = ref.watch(unreadCountProvider);

    final name = user.name.split(" ").first;
    final progress =
        ((user.xp ?? 0) / (user.nextLevelXp ?? 1)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ───────── HEADER ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    _Avatar(name: name),

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

                    _Notif(count: notifications),
                  ],
                ),
              ),
            ),

            // ───────── CONTENT ─────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  const SizedBox(height: 14),

                  // ───── KPI BLOCK ─────
                  _KPI(
                    xp: user.xp ?? 0,
                    next: user.nextLevelXp ?? 100,
                    progress: progress,
                  ),

                  const SizedBox(height: 16),

                  // ───── FEATURE BLOCK ─────
                  _Feature(
                    onTap: () => _open(
                      context,
                      "https://bepractical.tech",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ───── SECTION ─────
                  const _Title("Recommended Internships"),

                  const SizedBox(height: 10),

                  internships.when(
                    data: (data) => _Internship(data: data),
                    loading: () => const _Skeleton(),
                    error: (_, __) =>
                        const Text("Failed to load internships"),
                  ),

                  const SizedBox(height: 20),

                  const _Title("Skill Progress"),

                  const SizedBox(height: 10),

                  skills.when(
                    data: (data) {
                      final list = data.take(3);

                      return Column(
                        children: list.map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PrimaryCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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

/// ───────────────────────── COMPONENTS ─────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

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

class _Notif extends StatelessWidget {
  final int count;
  const _Notif({required this.count});

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

class _KPI extends StatelessWidget {
  final int xp;
  final int next;
  final double progress;

  const _KPI({
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
            "Learning Overview",
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
              fontSize: 28,
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

class _Feature extends StatelessWidget {
  final VoidCallback onTap;
  const _Feature({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF111827),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Build Industry Experience",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
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
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _Internship extends StatelessWidget {
  final List<Internship> data;
  const _Internship({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Text("No internships");

    final i = data.first;

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

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

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
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
