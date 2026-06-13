import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../viewmodel/internship_provider.dart';
import '../components/cards/internship_card.dart';
import '../components/common/loading_widget.dart';

class InternshipsScreen extends ConsumerStatefulWidget {
  const InternshipsScreen({super.key});

  @override
  ConsumerState<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends ConsumerState<InternshipsScreen> {
  late TextEditingController _searchController;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(activeFilterProvider);
    final filteredInternships = ref.watch(filteredInternshipsProvider);
    final trendingInternships = ref.watch(trendingInternshipsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Explore',
          style: AppTextStyles.display.copyWith(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find your dream opportunity',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Focus(
                          onFocusChange: (focus) => setState(() => _isSearchFocused = focus),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            decoration: BoxDecoration(
                              color: _isSearchFocused ? Colors.white : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                              border: Border.all(
                                color: _isSearchFocused ? AppColors.accent : AppColors.border,
                                width: _isSearchFocused ? 2 : 1.5,
                              ),
                              boxShadow: _isSearchFocused
                                  ? [BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]
                                  : [],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                              decoration: InputDecoration(
                                hintText: 'Search internships...',
                                prefixIcon: Icon(Icons.search_rounded, color: _isSearchFocused ? AppColors.accent : AppColors.muted),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          
          filteredInternships.when(
            data: (internships) {
              if (internships.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('No internships found')));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final i = internships[index];
                      final hasApplied = ref.watch(applicationStatusProvider(i.id)).value ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: InternshipCard(
                          logo: i.logo,
                          company: i.company,
                          position: i.position,
                          location: i.location,
                          salary: i.salary,
                          skills: i.skills,
                          matchPercentage: i.matchPercentage,
                          onApply: () => _handleApply(i.id, i.company),
                          onBookmark: () {}, // Implement bookmark logic
                          isBookmarked: i.saved,
                          isApplied: hasApplied,
                        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1),
                      );
                    },
                    childCount: internships.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: LoadingWidget()),
            error: (err, _) => SliverToBoxAdapter(child: Text('Error: $err')),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Future<void> _handleApply(String id, String company) async {
    try {
      final service = ref.read(internshipServiceProvider);
      await service.applyToInternship(id);
      
      ref.invalidate(applicationStatusProvider(id));
      ref.invalidate(userApplicationsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied to $company! Check your inbox ✨'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
