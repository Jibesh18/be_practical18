import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/buttons/primary_button.dart';
import '../components/buttons/secondary_button.dart';
import '../model/internship.dart';
import '../viewmodel/internship_provider.dart';

class InternshipDetailScreen extends ConsumerStatefulWidget {
  final Internship internship;
  const InternshipDetailScreen({super.key, required this.internship});

  @override
  ConsumerState<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends ConsumerState<InternshipDetailScreen> {
  bool _isSaved = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.internship.saved;
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.internship;
    final hasAppliedAsync = ref.watch(applicationStatusProvider(i.id));
    final hasApplied = hasAppliedAsync.value ?? false;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            // FIXED: Added leading button to ensure user can go back
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient)
                ),
                child: Center(child: Text(i.logo, style: const TextStyle(fontSize: 80))),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() => _isSaved = !_isSaved);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'), 
                      behavior: SnackBarBehavior.floating
                    ),
                  );
                },
                icon: Icon(_isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1), 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text('APPLICATIONS OPEN', 
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      const Spacer(),
                      // NEW: Price Display
                      Text(i.price, style: AppTextStyles.heading.copyWith(color: AppColors.secondary, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(i.position, style: AppTextStyles.display.copyWith(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
                  Text(i.company, style: AppTextStyles.subheading.copyWith(color: AppColors.muted)),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailInfo(label: 'Duration', value: i.duration, icon: Icons.timer_outlined),
                      _DetailInfo(label: 'Type', value: i.type, icon: Icons.laptop_rounded),
                      _DetailInfo(label: 'Seats', value: '${i.seatsLeft} left', icon: Icons.people_outline),
                    ],
                  ),

                  const SizedBox(height: 40),
                  _Section(title: 'About the Company', content: i.description),
                  _ListSection(title: 'Requirements', items: i.requirements),
                  _ListSection(title: 'Your Responsibilities', items: i.responsibilities),
                  
                  const SizedBox(height: 40),
                  if (hasApplied)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('You have applied', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    )
                  else
                    PrimaryButton(
                      label: _isApplying ? 'Processing...' : 'Apply Now',
                      isLoading: _isApplying,
                      onPressed: () => _handleApply(),
                    ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Visit Website', 
                    icon: Icons.open_in_new_rounded, 
                    onPressed: () async {
                      String website = i.website.trim();
                      if (website.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Website currently unavailable'), backgroundColor: Colors.orange),
                          );
                        }
                        return;
                      }
                      if (!website.startsWith('http://') && !website.startsWith('https://')) {
                        website = 'https://$website';
                      }
                      final uri = Uri.tryParse(website);
                      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Website currently unavailable'), backgroundColor: Colors.orange),
                          );
                        }
                        return;
                      }
                      bool launched = false;
                      try {
                        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (_) {
                        launched = false;
                      }
                      if (!launched) {
                        try {
                          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
                        } catch (_) {
                          launched = false;
                        }
                      }
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Website currently unavailable'), backgroundColor: Colors.orange),
                        );
                      }
                    }
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApply() async {
    setState(() => _isApplying = true);
    try {
      final service = ref.read(internshipServiceProvider);
      await service.applyToInternship(widget.internship.id);
      
      // Invalidate the providers to fetch latest data
      ref.invalidate(applicationStatusProvider(widget.internship.id));
      ref.invalidate(userApplicationsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application Submitted Successfully! ✨'), 
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating
          )
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error)
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }
}

class _DetailInfo extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _DetailInfo({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: AppColors.accent),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      Text(label, style: AppTextStyles.caption),
    ],
  );
}

class _Section extends StatelessWidget {
  final String title, content;
  const _Section({required this.title, required this.content});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: Colors.black)),
      const SizedBox(height: 10),
      Text(content, style: const TextStyle(height: 1.6, color: Colors.black87)),
      const SizedBox(height: 32),
    ]
  );
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  const _ListSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: Colors.black)),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16), 
          const SizedBox(width: 12), 
          Expanded(child: Text(item, style: const TextStyle(color: Colors.black87)))
        ]),
      )),
      const SizedBox(height: 32),
    ]
  );
}
