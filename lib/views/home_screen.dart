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

Future<void> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

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

    final name = (user.name.isNotEmpty) ? user.name.split(" ").first : "User";

    final xp = user.xp ?? 0;
    final next = user.nextLevelXp ?? 1;
    final progress = xp / next;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [

            const SizedBox(height: 16),

            // HEADER
            Row(
              children: [
                _Avatar(name: name),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
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
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // XP
            PrimaryCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "$xp XP",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LINK CARD
            GestureDetector(
              onTap: () => _openUrl("https://bepractical.tech"),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Open Academy",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Internships",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            internships.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text("Error loading internships"),
              data: (list) {
                if (list.isEmpty) {
                  return const Text("No internships");
                }

                return Column(
                  children: list.take(3).map((i) {
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
            ),

            const SizedBox(height: 20),

            const Text(
              "Skills",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            skills.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (list) {
                return Column(
                  children: (list as List).take(3).map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PrimaryCard(
                        padding: const EdgeInsets.all(14),
                        child: Text(s.name?.toString() ?? "Skill"),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
