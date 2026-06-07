import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/auth_provider.dart';
import '../viewmodel/internship_provider.dart';
import '../viewmodel/skill_provider.dart';
import '../viewmodel/notification_provider.dart';
import '../model/internship.dart';
import '../components/cards/primary_card.dart';
import '../components/common/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Opens the Academy website in an external browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final internshipsAsync = ref.watch(allInternshipsProvider);
    final skillsAsync = ref.watch(skillsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    if (user == null) {
      return const Scaffold(body: LoadingWidget(message: 'Initializing Be Practical Aura...'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. PREMIUM AURA BACKGROUND GLOWS
          Positioned(
            top: -150,
            left: -100,
            child: _AuraGlow(color: AppColors.accent.withValues(alpha: 0.12), size: 500),
          ),
          Positioned(
            bottom: 100,
            right: -150,
            child: _AuraGlow(color: AppColors.tertiary.withValues(alpha: 0.08), size: 600),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 2. 3D BRANDED HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        // Small 3D Brand Box
                        const _Small3DLogo().animate().scale(
                            duration: 800.ms,
                            curve: Curves.easeOutBack
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Be Practical',
                              style: AppTextStyles.heading.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -1,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Hi, ${user.name.split(' ')[0]} 👋',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
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
                      // 3. XP PROGRESS GLASS BAR
                      _buildXPStatus(user),

                      const SizedBox(height: 32),

                      // 4. ACADEMY PROMO (Opens Website)
                      _buildAcademyPromoCard(),

                      const SizedBox(height: 32),

                      _SectionHeader(
                        title: 'Recommended For You',
                        action: 'Explore',
                        onAction: () => context.push('/internships'),
                      ),
                      const SizedBox(height: 16),

                      // 5. INTERNSHIP LIST
                      _buildInternshipList(internshipsAsync, context),

                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Active Skill Paths'),
                      const SizedBox(height: 16),

                      // 6. SKILLS GRID
                      _buildSkillsGrid(skillsAsync, context),

                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPStatus(dynamic user) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP PROGRESS', style: AppTextStyles.label.copyWith(color: AppColors.muted)),
              Text('${user.xp} / ${user.nextLevelXp} XP', style: AppTextStyles.label.copyWith(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: user.xp / user.nextLevelXp,
              minHeight: 10,
              backgroundColor: AppColors.border.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildAcademyPromoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.auraGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PREMIUM ENROLLMENT',
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Be Practical Academy',
                    style: AppTextStyles.subheading.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock 100+ industrial projects and guaranteed internship placement.',
                    style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _launchURL('https://bepractical.tech'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('VISIT ACADEMY', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: const Icon(Icons.school_rounded, size: 150, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildInternshipList(AsyncValue<List<Internship>> asyncData, BuildContext context) {
    return asyncData.when(
      data: (data) => SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final i = data[index];
            return Container(
              width: 260,
              margin: const EdgeInsets.only(right: 16),
              child: PrimaryCard(
                onTap: () => context.push('/internship/${i.id}'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(i.logo, style: const TextStyle(fontSize: 28)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: i.price == 'Free' ? AppColors.success.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            i.price,
                            style: TextStyle(
                                color: i.price == 'Free' ? AppColors.success : AppColors.secondary,
                                fontWeight: FontWeight.w900,
                                fontSize: 10
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(i.position, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(i.company, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('${i.matchPercentage}% Match', style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.accent)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => const Text('Error loading matches'),
    );
  }

  Widget _buildSkillsGrid(AsyncValue<dynamic> asyncData, BuildContext context) {
    return asyncData.when(
      data: (data) {
        final List skills = data as List;
        return Column(
          children: skills.take(4).map<Widget>((skill) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PrimaryCard(
              onTap: () => context.push('/skills'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    height: 48, width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.code_rounded, color: AppColors.accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                        Text('${skill.lessons.length} Professional Lessons', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.border),
                ],
              ),
            ),
          )).toList(),
        );
      },
      loading: () => const SizedBox(),
      error: (err, _) => const SizedBox(),
    );
  }
}

class _Small3DLogo extends StatelessWidget {
  const _Small3DLogo();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(
          'assets/images/applogo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
              child: Text('BP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotificationBadge({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
            ),
            child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
          ),
          if (count > 0)
            Positioned(
              right: -2, top: -2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
            ),
        ],
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
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w900, color: Colors.black)),
      if (action != null)
        TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900))),
    ],
  );
}

class _AuraGlow extends StatelessWidget {
  final Color color;
  final double size;
  const _AuraGlow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)])),
  );
}
