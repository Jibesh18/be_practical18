import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../components/cards/primary_card.dart';
import '../components/common/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final unreadCount = ref.watch(unreadCountProvider);
    final internshipsAsync = ref.watch(allInternshipsProvider);
    final skillsAsync = ref.watch(skillsProvider);
    final applicationsAsync = ref.watch(userApplicationsProvider);

    if (user == null) {
      return const Scaffold(body: LoadingWidget(message: 'Initializing Be Practical...'));
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
                            Text('Be Practical', style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1, color: Colors.black)),
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
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Your Applications', action: 'View All', onAction: () => context.push('/internships')),
                      const SizedBox(height: 16),
                      _buildApplicationsDashboard(applicationsAsync),
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Recommended For You', action: 'Explore', onAction: () => context.push('/internships')),
                      const SizedBox(height: 16),
                      _buildInternshipList(internshipsAsync, context),
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Active Skill Paths'),
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

  Widget _buildApplicationsDashboard(AsyncValue<List<Map<String, dynamic>>> asyncData) {
    return asyncData.when(
      data: (apps) {
        int total = apps.length;
        int pending = apps.where((a) => a['status'] == 'Under Review' || a['status'] == 'Applied').length;
        int accepted = apps.where((a) => a['status'] == 'Accepted').length;

        return Row(
          children: [
            Expanded(child: _StatCard(title: 'Total', count: total, color: AppColors.primary, icon: Icons.description_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Pending', count: pending, color: Colors.orange, icon: Icons.pending_actions_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Accepted', count: accepted, color: AppColors.success, icon: Icons.check_circle_rounded)),
          ],
        ).animate().fadeIn().slideX(begin: -0.1);
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildInternshipList(AsyncValue<List<dynamic>> asyncData, BuildContext context) {
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
                          child: Text(i.price, style: TextStyle(color: i.price == 'Free' ? AppColors.success : AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 10)),
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
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => const Text('Error loading matches'),
    );
  }

  Widget _buildSkillsGrid(AsyncValue<List<dynamic>> asyncData, BuildContext context) {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: Colors.black)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppTextStyles.label.copyWith(color: AppColors.accent)),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(count.toString(), style: AppTextStyles.heading.copyWith(color: color, fontSize: 24)),
          Text(title, style: AppTextStyles.caption.copyWith(color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
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
