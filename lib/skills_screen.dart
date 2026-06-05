import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/skill_provider.dart';
import '../components/common/skill_progress_ring.dart';
import '../components/common/loading_widget.dart';
import '../components/cards/primary_card.dart';

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Skills',
          style: AppTextStyles.display.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Streak Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🔥', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '24 Day Streak',
                          style: AppTextStyles.subheading.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'You\'re on fire! Keep it up.',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const Text('🏆', style: TextStyle(fontSize: 70)).animate(
                      onPlay: (c) => c.repeat(reverse: true),
                    ).scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.xl2),
              
              // Stats Row
              Row(
                children: [
                  _StatCard(label: 'Courses', value: '12', color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(label: 'Completed', value: '8', color: AppColors.success),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(label: 'Growth', value: '+24%', color: AppColors.accent),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: AppSpacing.xl2),
              
              Text(
                'Your Expertise',
                style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.lg),

              skillsAsync.when(
                data: (skills) {
                  return Column(
                    children: skills.asMap().entries.map((entry) {
                      final index = entry.key;
                      final skill = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: PrimaryCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        skill.name,
                                        style: AppTextStyles.subheading.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Level ${skill.level}',
                                          style: AppTextStyles.label.copyWith(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SkillProgressRing(
                                    currentXp: skill.xp,
                                    maxXp: skill.maxXp,
                                    size: 64,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: 1.seconds,
                                    height: 10,
                                    width: (MediaQuery.of(context).size.width - 80) * (skill.xp / skill.maxXp),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: AppColors.accentGradient),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                  ).animate().shimmer(duration: 2.seconds),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${skill.xp} / ${skill.maxXp} XP',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(begin: 0.05),
                      );
                    }).toList(),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (err, _) => Text('Error: $err'),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              Text(
                'Achievements',
                style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final achievements = [
                    ('🏅', 'First Step'), ('🚀', 'Rocket'), ('🔥', 'On Fire'),
                    ('💪', 'Strong'), ('🎯', 'Goal'), ('⭐', 'Star'),
                  ];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(achievements[index].$1, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          achievements[index].$2,
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w800, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().scale(delay: (600 + (index * 50)).ms);
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading.copyWith(color: color, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
