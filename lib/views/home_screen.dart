import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/auth_provider.dart';
import '../viewmodel/internship_provider.dart';
import '../viewmodel/notification_provider.dart';
import '../components/cards/gradient_card.dart';
import '../components/common/loading_widget.dart';
import '../components/cards/primary_card.dart';
import '../components/buttons/primary_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _gainXp(WidgetRef ref, BuildContext context, int xp, String action) {
    ref.read(authProvider.notifier).addXp(xp);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Text('✨ ', style: TextStyle(fontSize: 20)),
          Text('You earned $xp XP for $action!'),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final internshipsAsync = ref.watch(allInternshipsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    if (user == null) return const Scaffold(body: LoadingWidget(message: 'Initializing Be Practical Aura...'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // Aura Background Orbs
          Positioned(
            top: -100,
            left: -50,
            child: _AuraGlow(color: AppColors.accent.withValues(alpha: 0.1), size: 400),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: _AuraGlow(color: AppColors.secondary.withValues(alpha: 0.05), size: 500),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium 3D Branded Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const _Small3DLogo().animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Be Practical',
                              style: AppTextStyles.heading.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Welcome back, ${user.name.split(' ')[0]}',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _NotificationBadge(count: unreadCount, onTap: () => context.push('/notifications')),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 12),
                      
                      // Daily Challenge Section
                      _buildDailyGoalCard(ref, context),
                      
                      const SizedBox(height: 32),
                      _SectionHeader(
                        title: 'Recommended For You',
                        action: 'View All',
                        onAction: () => context.push('/internships'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Horizontal Internship List
                      _buildInternshipHorizontalList(internshipsAsync, context),

                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Continue Learning'),
                      const SizedBox(height: 16),
                      
                      // Neon Progress Card
                      _buildContinueLearningCard(context),
                      
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Live Challenges'),
                      const SizedBox(height: 16),
                      _buildQuizCard(ref, context),
                      
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

  Widget _buildDailyGoalCard(WidgetRef ref, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: GradientCard(
        gradient: AppColors.primaryGradient,
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily Quest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                      Text('Complete 1 lesson to earn 500 XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'CLAIM XP REWARD',
              onPressed: () => _gainXp(ref, context, 500, "Daily Quest"),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildInternshipHorizontalList(dynamic internshipsAsync, BuildContext context) {
    return internshipsAsync.when(
      data: (data) => SizedBox(
        height: 190,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final i = data[index];
            return Container(
              width: 240,
              margin: const EdgeInsets.only(right: 20),
              child: PrimaryCard(
                onTap: () => context.push('/internship/${i.id}'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                          child: Text(i.logo, style: const TextStyle(fontSize: 24)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('${i.matchPercentage}% Match', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(i.position, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(i.company, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(i.location, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildContinueLearningCard(BuildContext context) {
    return PrimaryCard(
      onTap: () => context.push('/skills'),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            height: 56, width: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.accentGradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Flutter Mastery', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const Text('Lesson 14: 3D Render', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(value: 0.82, backgroundColor: Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation(AppColors.secondary), minHeight: 6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('82%', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildQuizCard(WidgetRef ref, BuildContext context) {
    return PrimaryCard(
      color: AppColors.secondary.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Real-World Quiz', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                SizedBox(height: 4),
                Text('Test your skills and earn +200 XP.', style: TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _gainXp(ref, context, 200, "Daily Quiz"),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
            ),
            child: const Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _Small3DLogo extends StatelessWidget {
  const _Small3DLogo();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
          const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset('assets/images/applogo.png', fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('BP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
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
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1.5),
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
      Text(title, style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
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
