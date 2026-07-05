import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/auth_provider.dart';
import '../components/cards/primary_card.dart';

class CompanyHomeScreen extends ConsumerWidget {
  const CompanyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: _AuraGlow(color: AppColors.secondary.withValues(alpha: 0.12), size: 500),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const _CompanyLogoBox(),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Company Portal', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
                            Text('Hi, ${user?.name ?? "Recruiter"}', style: AppTextStyles.heading.copyWith(fontSize: 24, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      _buildStatsOverview(),
                      const SizedBox(height: 32),
                      _buildActionCard(
                        title: 'Post New Internship',
                        subtitle: 'Find the best talent for your projects',
                        icon: Icons.add_circle_outline_rounded,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      _buildActionCard(
                        title: 'Manage Applications',
                        subtitle: 'Review and shortlist candidates',
                        icon: Icons.people_outline_rounded,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 32),
                      Text('Active Postings', style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      _buildEmptyState(),
                      const SizedBox(height: 100),
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

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Active Jobs', value: '0', color: AppColors.accent)),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(label: 'Total Applicants', value: '0', color: AppColors.secondary)),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color color}) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900)),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.border),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildEmptyState() {
    return PrimaryCard(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.work_outline_rounded, size: 48, color: AppColors.border),
            const SizedBox(height: 16),
            Text('No active postings yet', style: AppTextStyles.body.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => PrimaryCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.display.copyWith(fontSize: 32, color: color, fontWeight: FontWeight.w900)),
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class _CompanyLogoBox extends StatelessWidget {
  const _CompanyLogoBox();
  @override
  Widget build(BuildContext context) => Container(
    width: 55, height: 55,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 2),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
    ),
    child: const Icon(Icons.business_rounded, color: AppColors.primary, size: 30),
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

