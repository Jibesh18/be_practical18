import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        const _Small3DLogo().animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Be Practical', style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.black)),
                            Text('Master your future, ${user.name.split(' ')[0]}', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const Spacer(),
                        _NotificationBadge(count: unreadCount, onTap: () => context.push('/notifications')),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildXPStatus(user),
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Recommended For You', action: 'Explore', onAction: () => context.push('/internships')),
                      const SizedBox(height: 16),
                      _buildInternshipList(internshipsAsync, context),
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Active Skills'),
                      const SizedBox(height: 16),
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
                    Text(i.logo, style: const TextStyle(fontSize: 28)),
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

  Widget _buildSkillsGrid(dynamic asyncData, BuildContext context) {
    return asyncData.when(
      data: (data) => Column(
        children: data.take(4).map<Widget>((skill) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PrimaryCard(
            onTap: () => context.push('/skills'),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  height: 48, width: 48,
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
      ),
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
        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset('assets/images/applogo.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Text('BP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
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
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
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
