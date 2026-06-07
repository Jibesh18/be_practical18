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

/// ───────────────────────── SAFE URL ─────────────────────────
Future<void> openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
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
        body: LoadingWidget(message: "Loading..."),
      );
    }

    final internships = ref.watch(allInternshipsProvider);
    final skills = ref.watch(skillsProvider);
    final notif = ref.watch(unreadCountProvider);

    final name = user.name.isNotEmpty ? user.name.split(" ").first : "User";

    final xp = user.xp ?? 0;
    final next = (user.nextLevelXp ?? 1).clamp(1, 999999);
    final progress = xp / next;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [

            const SizedBox(height: 16),

            _Header(name: name, notif: notif),

            const SizedBox(height: 16),

            _XPSection(xp: xp, progress: progress),

            const SizedBox(height: 14),

            _AcademyBanner(
              onTap: () => openLink("https://bepractical.tech"),
            ),

            const SizedBox(height: 20),

            _SectionTitle("Recommended Internships"),

            const SizedBox(height: 10),

            _InternshipSection(data: internships),

            const SizedBox(height: 20),

            _SectionTitle("Skill Paths"),

            const SizedBox(height: 10),

            _SkillSection(data: skills),

            const SizedBox(height: 80),
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
  final int notif;

  const _Header({required this.name, required this.notif});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(name: name),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        Stack(
          children: [
            const Icon(Icons.notifications_none),

            if (notif > 0)
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
                    "$notif",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

//
// ───────────────────────── XP SECTION ─────────────────────────
//
class _XPSection extends StatelessWidget {
  final int xp;
  final double progress;

  const _XPSection({
    required this.xp,
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
            "Your Progress",
            style: TextStyle(
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
            ),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }
}

//
// ───────────────────────── BANNER ─────────────────────────
//
class _AcademyBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AcademyBanner({required this.onTap});

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
              child: Text(
                "Be Practical Academy — Start your career journey",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.white),
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
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text("Failed to load internships"),
      data: (list) {
        if (list.isEmpty) return const Text("No internships");

        return Column(
          children: list.take(2).map((i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PrimaryCard(
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
                        ],
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
                child: Text(s.name ?? "Skill"),
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
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "U",
          style: const TextStyle(color: Colors.white),
        ),
      ),
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
